# AFT Customizations

[AWS Account Factory for Terraform (AFT)](https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html)
is the bridge between AWS Control Tower's Account Factory and Terraform. It
provisions accounts via Control Tower, then runs Terraform pipelines per
account on creation and on subsequent updates.

This directory contains **example customizations** that drop the modules
from this template into AFT's expected layout. Use these as a starting
point if you're running AFT and want to consume our modules.

## When this matters

| You... | Use |
|---|---|
| Run a fresh AWS Org with Control Tower + AFT | These customizations |
| Have a pure-Terraform org (no Control Tower) | `medium/` or `large/` deployments directly |
| Run Control Tower but not AFT | Either: write your own Terraform that consumes our modules, or adopt AFT and use this |

Most enterprises that already have Control Tower also have AFT — they go
together.

## AFT's 4-repo model

AFT expects 4 separate Git repositories (or 4 subdirectories that you split
into separate repos during AFT bootstrap):

| Repo | Purpose | Mirror here |
|---|---|---|
| `aft-account-request` | New-account requests as Terraform code | `account-request/` |
| `aft-global-customizations` | Applied to **every** AFT-managed account | `global-customizations/` |
| `aft-account-customizations` | Applied per account-type (one subdir per type) | `account-customizations/` |
| `aft-account-provisioning-customizations` | Runs **during** Control Tower account provisioning, before the global + account customizations | `account-provisioning-customizations/` |

## Wiring our modules into AFT

The pattern is the same in each customization repo:

```hcl
# aft-global-customizations/terraform/baseline.tf

module "workload_baseline" {
  source = "git::https://github.com/satishbabariya/enterprise-aws-terraform.git//modules/workload-baseline?ref=main"

  org_name                = "acme"
  account_name            = "${local.aft_account_name}"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  log_archive_bucket_arn  = "arn:aws:s3:::acme-us-east-1-log-archive"
  log_archive_bucket_name = "acme-us-east-1-log-archive"
  github_org              = "acme"
  github_repo             = "infrastructure"
}
```

The key insight: **AFT runs Terraform in each account's context**, so the
provider is already configured to deploy into the right account. You don't
need `assume_role` blocks like you do in the `medium/` / `large/`
deployments.

## What's in each example

### `global-customizations/`

Applied to every account AFT creates. Drops our `workload-baseline`
composite + `vpc` + `cloudtrail` event subscription so every account gets
the standard baseline.

### `account-customizations/workload-prod/`

Applied to accounts requested with `account_type = "workload-prod"`. Adds
prod-specific layers: multi-AZ NAT, encrypted EBS by default, deletion
protection on data resources.

### `account-customizations/workload-non-prod/`

Applied to accounts with `account_type = "workload-non-prod"`. Cheaper:
single NAT gateway, shorter log retention, no deletion protection.

### `account-request/`

Example new-account request that demonstrates how to ask AFT to vend an
account with a specific account-type. The `custom_fields` map carries
through to your customizations.

### `account-provisioning-customizations/`

Runs as a Step Function during Control Tower account provisioning, before
the customization pipelines start. Use this for things that must exist
before the global pipeline runs (account-level password policy, default
EBS encryption).

## Bootstrapping AFT itself

This template doesn't install AFT for you — that's a one-time AWS-published
Terraform deployment. See:
https://github.com/aws-ia/terraform-aws-control_tower_account_factory

After AFT is bootstrapped, copy this directory's subdirs into the 4 AFT
repos AFT created in your AWS CodeCommit (or wherever you pointed it).

## Trade-offs vs. direct deployment

| | AFT + this template | Direct (`medium/`, `large/`) |
|---|---|---|
| Account creation | AFT pipeline (~30 min per account) | `module.account_vending` in management Terraform |
| Customization | 4 separate repos | 1 monorepo |
| Operational burden | AFT pipelines + CodeCommit + Lambdas to maintain | Just Terraform |
| AWS-supported | Yes | No (community pattern) |
| Vendor lock-in | High (Control Tower) | None |
| Multi-region story | Limited (Control Tower home region locked) | Flexible |
| Cost | +$200–500/month for AFT pipeline infra | $0 extra |

Pick AFT if you want AWS-supported account vending and don't mind the
operational overhead. Pick direct deployment if you want full Terraform
ownership.

See [`docs/migration-from-existing-org.md`](../docs/migration-from-existing-org.md)
for the third option: incremental adoption that works for either pattern.
