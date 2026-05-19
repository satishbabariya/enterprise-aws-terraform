# Migration: Existing AWS Org → This Template

Greenfield deployment of this template is documented in
[`docs/onboarding.md`](onboarding.md). This guide is for the harder case:
you already have an AWS Organization with accounts, IAM, possibly some
CloudTrail / Config / SCPs in place, and you want to bring it under this
template's IaC without disruption.

## Realistic timeline

A typical migration runs **8–12 weeks**:

| Phase | Duration | Focus |
|---|---|---|
| 1. Inventory + decide | 1 week | What exists, what to keep, what to replace |
| 2. State bootstrap + import | 2 weeks | Get Terraform tracking existing resources |
| 3. Detective controls | 2 weeks | Security Hub + GuardDuty + Config conformance packs |
| 4. Identity centralization | 1–2 weeks | Switch humans to Identity Center |
| 5. Preventive controls (SCPs) | 2–3 weeks | Roll out SCPs OU by OU, monitor for breakage |
| 6. Baseline templating | 2 weeks | Adopt workload-baseline / vpc / cloudtrail modules |
| 7. Decommission legacy | Ongoing | Remove the old setup once parallel is verified |

The right time to do this is **not** under pressure. Migrations that try to
ship preventive guardrails in week 1 break things.

## Phase 1: Inventory

Before any code changes, build an inventory:

```bash
# What accounts exist
aws organizations list-accounts --output json > existing-accounts.json

# What OUs exist
aws organizations list-organizational-units-for-parent \
  --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text)

# What SCPs are attached
aws organizations list-policies --filter SERVICE_CONTROL_POLICY
for policy_id in $(aws organizations list-policies --filter SERVICE_CONTROL_POLICY \
    --query 'Policies[?AwsManaged==`false`].Id' --output text); do
  aws organizations list-targets-for-policy --policy-id "$policy_id"
done

# What CloudTrail trails exist
aws cloudtrail list-trails

# Which accounts have Security Hub / GuardDuty / Config enabled
# Run from delegated admin or each account
aws securityhub describe-hub  # per region per account
aws guardduty list-detectors
aws configservice describe-configuration-recorders
```

Document everything in a spreadsheet:

| Account ID | Name | OU | Workload | Last touched by Terraform? | Has CloudTrail? | Has Config? | Has SCPs? |
|---|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | ... | ... |

## Phase 2: State bootstrap + import

### 2a. Run the bootstrap

The bootstrap module creates the Terraform state S3 bucket and DynamoDB lock
table. **This does not touch any existing resources.**

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Set your existing management_account_id
terraform init
terraform apply
terraform init -migrate-state
```

### 2b. Import the AWS Organization

The `aws-organization` module assumes greenfield. For an existing org you
need to **import** rather than create:

```hcl
# In medium/accounts/management/main.tf (already wired)
import {
  to = module.organization.aws_organizations_organization.this
  id = "o-xxxxxxxxxx"  # your real org ID from `aws organizations describe-organization`
}

# For each existing OU:
import {
  to = module.organization.aws_organizations_organizational_unit.this["security"]
  id = "ou-xxxx-xxxxxxxx"  # your real OU ID
}
# ... repeat per OU
```

Run `terraform plan` and verify it shows **only attribute drift** (not
"create" / "destroy"). Then apply. Imports happen at apply time in
Terraform 1.5+.

### 2c. Import each existing foundation account

For accounts that already exist, set `account_id` in the `accounts` map
(don't set `email` — that triggers vending):

```hcl
# medium/accounts/management/terraform.tfvars
accounts = {
  security    = { ou_key = "security", account_id = "111111111111" }
  log-archive = { ou_key = "security", account_id = "222222222222" }
  # ... existing accounts
}
```

No actual account creation happens because the entries supply `account_id`.

## Phase 3: Detective controls (safe to enable in parallel)

Detective controls don't block anything — they observe. Roll these out
first to build org-wide visibility without risking production:

```hcl
# In the security account root, enable detection services
module "security_hub" { ... }
module "guardduty"   { ... }
module "aws_config"  { ... }
module "macie"       { ... }
module "inspector"   { ... }
module "access_analyzer" { ... }
```

If any account already has GuardDuty enabled in a non-delegated-admin
configuration, you have two choices:

1. **Disable then re-enable from delegated admin** (clean, but loses
   historical findings — they don't move)
2. **Enable as delegated admin and accept existing detectors as members**
   (preserves findings but the AWS API doesn't migrate detectors; you'll
   have duplicates briefly while you decommission old ones)

Most orgs accept option 1 for non-critical accounts and option 2 for prod.

## Phase 4: Identity Center centralization

If you already have IAM Identity Center deployed, **import it**:

```hcl
import {
  to = module.identity_center.aws_ssoadmin_permission_set.this["AdministratorAccess"]
  id = "arn:aws:sso:::permissionSet/ssoins-xxxx/ps-xxxx,arn:aws:sso:::instance/ssoins-xxxx"
}
```

If you're moving from IAM users to Identity Center:

1. Stand up Identity Center in management account (`modules/identity-center`)
2. Assign all existing humans to the right groups (see [`docs/access-management.md`](access-management.md))
3. **Run for 2-4 weeks with both old and new working in parallel**
4. Deactivate IAM user access keys (don't delete users yet — leave for audit trail)
5. Once SCPs land in Phase 5, IAM user creation will be blocked entirely

## Phase 5: SCP rollout (highest-risk phase)

SCPs are preventive — they can break workloads if you attach them too
aggressively. Roll out one OU at a time:

### Order

1. **Sandbox OU first** — lowest blast radius
2. **Workloads Dev OU** — catch issues with safety margin
3. **Workloads Staging OU** — final test before prod
4. **Workloads Prod OU** — only after weeks of monitoring earlier OUs
5. **Infrastructure OU** — VPC mutations etc.
6. **Security OU** — last (these are the accounts that monitor)

### Per-policy guidance

| Policy | Risk | When to attach |
|---|---|---|
| `DenyRootActions` | None — nobody should use root | Root OU, immediately |
| `DenyLeaveOrganization` | None | Root OU, immediately |
| `DenyNonApprovedRegions` | High — workloads in non-listed regions break | Workloads OU only after verifying all resources are in approved regions |
| `RequireIMDSv2` | Medium — apps using IMDSv1 break | Workloads OU after surveying EC2 launch templates |
| `DenyS3PublicAccess` | High — public S3 buckets (CloudFront origins) break | Workloads OU after auditing public buckets |
| `DenyIAMUserCreation` | Low if Identity Center is fully rolled out | Workloads OU after Phase 4 complete |
| `DenyUnencryptedStorage` | High — legacy EBS volumes / RDS instances without encryption fail to launch | Workloads OU after verifying no unencrypted resources |
| `DenyVPCChanges` | High — blocks app teams from touching networking | Infrastructure OU only |

For each SCP, do this dance:

```bash
# 1. Attach to a single sandbox account first
aws organizations attach-policy --policy-id <scp> --target-id <sandbox-account-id>

# 2. Watch CloudTrail for AccessDenied for ~48 hours
# 3. If clean, attach to the OU:
aws organizations attach-policy --policy-id <scp> --target-id <ou-id>

# 4. Watch Security Hub findings for new failures over 1 week
# 5. Roll forward to next OU
```

The repo's CloudWatch metric filter on AccessDenied (CIS 3.1) will alert
you when SCPs deny actions. Use this proactively.

## Phase 6: Baseline templating

Existing accounts have ad-hoc VPCs, KMS keys, IAM roles, etc. The
`modules/workload-baseline` composite is designed to be additive — it adds
the missing pieces without overwriting existing ones.

For each existing workload account:

```hcl
# medium/accounts/<env>/main.tf

# Don't import existing VPC if you plan to keep it.
# Just baseline the account-level controls:
module "workload_baseline" {
  source                  = "../../../modules/workload-baseline"
  org_name                = var.org_name
  account_name            = var.account_name
  account_id              = var.account_id
  region                  = var.region
  log_archive_bucket_arn  = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org              = var.github_org
  github_repo             = var.github_repo
}

# IMPORT existing VPC instead of creating new one:
# 1. Add `module.vpc { source = "../../../modules/vpc"; ... }` block
# 2. import { to = module.vpc.aws_vpc.this; id = "vpc-xxx" }
# 3. terraform plan — verify zero changes
# 4. Iterate until clean
```

The hard part: existing VPCs often have non-conforming CIDR layouts, missing
EKS tags, or NAT gateways in unexpected places. Be prepared to either:

1. Adopt our module's opinions (tag the existing subnets, accept some drift)
2. Leave the existing VPC as-is and only adopt the *new* modules going forward

Option 2 is usually more pragmatic for migrations.

## Phase 7: Decommission legacy

After running parallel for 30–90 days and verifying:
- All SCPs attached without breakage
- All workloads use Identity Center (zero IAM user logins for 30 days)
- Detective controls firing correctly
- CloudTrail centralized to log-archive
- Old CloudTrail trails / Config recorders / GuardDuty detectors in member accounts can be removed

Run a final pass:

```bash
# Find non-template-managed CloudTrails
aws cloudtrail list-trails | jq '.Trails[] | select(.Name != "acme-org-trail")'

# Find lingering IAM users in workload accounts (after Identity Center migration)
aws iam list-users  # per workload account

# Find Config recorders that aren't ours
aws configservice describe-configuration-recorders  # per account
```

Delete what's safe to delete. Keep audit-relevant data (CloudTrail S3
archives, Security Hub findings) for the org's retention period.

## What to do when something goes wrong

| Problem | Recovery |
|---|---|
| SCP blocked legitimate workload | Detach the SCP from the OU immediately. Investigate. Re-attach with workload either fixed or whitelisted. |
| Imported a resource and Terraform wants to destroy it | Stop. Check the `import { to = ... id = ... }` block. The `id` format varies per resource — verify against `terraform import` docs. |
| `terraform plan` shows mass replacement after import | Likely an attribute mismatch (capitalization, default value). Use `terraform state show <resource>` to inspect actual state vs. config. Adjust config, repeat plan. |
| Identity Center migration locked out an admin | Use the break-glass IAM user you created in Phase 4. If you skipped that, AWS Support escalation. |
| GuardDuty findings duplicated after delegation | Disable old detectors in member accounts. Wait 7 days. Findings dedupe automatically. |
| New CloudTrail org trail conflicting with existing trail | Decide which is authoritative. Disable the other (don't delete; keep logs for 90 days). |

## What this template does NOT help with

- **Account splits**: if you need to split a 5-team account into 5 single-team accounts, that's a workload migration, not an org migration. Use AWS Account Move.
- **Region migrations**: if your existing org is in eu-west-1 and you want to move to us-east-1, this template can configure the new region but doesn't migrate data. Use AWS Database Migration Service / S3 batch operations.
- **Custom OU hierarchies**: this template assumes Security / Infrastructure / Workloads. If your existing org has 7 levels of OUs, simplify before migrating.
- **Pre-existing Control Tower deployments**: see [`docs/architecture.md`](architecture.md) for the comparison; Control Tower migration is out of scope.
