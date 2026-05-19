# Access Management

Human and workforce access is delivered via **IAM Identity Center** (formerly AWS
SSO). Groups are personas; permission sets are the AWS-side roles those personas
assume per account. No long-lived IAM users. No long-lived access keys. All
human access is federated and session-bound.

## Persona Matrix

| Group (SSO)            | Persona                                   | Permission Set            | Session | Accounts                                                          |
|------------------------|-------------------------------------------|---------------------------|---------|-------------------------------------------------------------------|
| `PlatformAdmins`       | SRE / platform team                       | `AdministratorAccess`     | 4h      | management, security, log-archive, network, shared-services       |
| `AppDevelopersProd`    | Application devs (prod read)              | `WorkloadDeveloperProd`   | 4h      | prod, staging                                                     |
| `AppDevelopersNonProd` | Application devs (non-prod write)         | `WorkloadDeveloperNonProd`| 8h      | dev, sandbox, staging                                             |
| `SecurityEngineers`    | Security team (incident response)         | `SecurityResponder`       | 4h      | security, log-archive                                             |
| `SecurityEngineers`    | Security team (audit elsewhere)           | `SecurityAudit`           | 8h      | management, network, shared-services, prod, staging, dev, sandbox |
| `Auditors`             | Internal/external auditors                | `ReadOnlyAccess`          | 8h      | ALL accounts                                                      |
| `FinanceTeam`          | Finance / FinOps                          | `BillingReadOnly`         | 8h      | management                                                        |
| `ExternalContractors`  | External contractors (limited write)      | `ExternalContractor`      | 2h      | dev, sandbox                                                      |
| `BreakGlass`           | Emergency admin (alerted)                 | `BreakGlassAdmin`         | 1h      | ALL accounts                                                      |

## Permission Set Detail

### Managed-policy-backed (defined in `modules/identity-center/variables.tf`)

| Name                  | Underlying policy                            |
|-----------------------|----------------------------------------------|
| `AdministratorAccess` | `arn:aws:iam::aws:policy/AdministratorAccess`|
| `PowerUserAccess`     | `arn:aws:iam::aws:policy/PowerUserAccess`    |
| `ReadOnlyAccess`      | `arn:aws:iam::aws:policy/ReadOnlyAccess`     |
| `SecurityAudit`       | `arn:aws:iam::aws:policy/SecurityAudit`      |
| `BillingReadOnly`     | `arn:aws:iam::aws:policy/job-function/Billing` |

### Custom personas (defined in `medium/accounts/management/access-assignments.tf`)

- **`WorkloadDeveloperProd`** — `ReadOnlyAccess` + inline `Deny` on IAM, Org,
  SSO, VPC mutations, KMS key deletion, S3 bucket deletion, and disabling any
  detective control (GuardDuty / Config / CloudTrail / Security Hub).

- **`WorkloadDeveloperNonProd`** — `PowerUserAccess` + inline `Deny` on IAM user
  creation, Organizations, SSO, and disabling detective controls. Developers
  can build whatever they need in dev/sandbox/staging but cannot escalate
  privileges or weaken security tooling.

- **`SecurityResponder`** — `AdministratorAccess` scoped to security + log-archive
  accounts only. Used during incident response.

- **`BreakGlassAdmin`** — `AdministratorAccess` with 1-hour session. Assumption
  triggers a CloudWatch metric filter -> CloudWatch alarm -> SNS topic
  (`<org>-break-glass-alerts`) that should page on-call.

- **`ExternalContractor`** — `PowerUserAccess` + inline `Deny` covering:
  - All IAM, Org, SSO, security-tool mutations
  - All actions when MFA is not present (`aws:MultiFactorAuthPresent = false`)
  - Optional: all actions from outside `external_contractor_allowed_ips` (set
    to your corporate VPN CIDRs to enforce)

## How to Onboard a Person

1. **Add the user in your IdP** (Okta / Azure AD / Google Workspace) or
   directly in IAM Identity Center.
2. **Assign them to a group** matching their persona — the group already has
   account+permission-set wiring via Terraform.
3. **Send them the AWS access portal URL** (find it in the Identity Center
   console). They authenticate, see only their authorized accounts, and click
   to assume a session.

No Terraform change is required to onboard a single user. Terraform manages
groups and account assignments; user-to-group membership lives in the identity
store (or in your upstream IdP for SCIM-synced setups).

## How to Add a New Persona

1. Add a group entry to `local.sso_groups` in `access-assignments.tf`.
2. (Optional) Add a custom permission set to `local.custom_permission_sets`.
3. Add assignment tuples to `local.account_assignments`.
4. `terraform apply` the management account.

## Break-Glass Procedure

1. On-call gets paged from `<org>-break-glass-alerts` SNS.
2. The assumption is in CloudTrail at the moment of use — pull the event:
   `aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithSAML --max-results 10`
3. Verify the responder had a valid incident ticket. File a post-incident
   review within 24 hours documenting why managed automation could not be
   used instead.

## External IdP Integration

To replace native Identity Center users with Okta/Azure AD/Google:

1. In Identity Center console -> Settings -> Identity source -> Change to
   "External identity provider".
2. Upload the IdP metadata XML; download the SCIM endpoint and bearer token.
3. Configure your IdP to push group + user provisioning to that SCIM
   endpoint.
4. Groups created by Terraform in `local.sso_groups` will appear in the IdP
   for membership management. Terraform owns the group resources; the IdP
   owns membership.

## Forbidden Patterns (enforced by SCPs)

- Creating IAM users in workload accounts (`DenyIAMUserCreation` SCP)
- Creating IAM access keys in workload accounts
- Long-lived credentials of any kind

Anything that needs programmatic access goes through:
- **GitHub Actions** -> OIDC -> per-account `<org>-<account>-terraform-ci` role
- **EC2/Lambda/ECS** -> task / instance roles
- **External tools** -> dedicated IAM role with `sts:AssumeRoleWithWebIdentity` and an external ID
