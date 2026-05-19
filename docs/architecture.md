# Architecture

## Account & OU Structure

See design spec: `docs/superpowers/specs/2026-05-18-enterprise-terraform-design.md`

## Deployment Dependency Graph

```
bootstrap (local state -> migrated to S3)
    |
    +-> management (Org, SCPs, Identity Center, CloudTrail, OIDC)
            |
            +-> log-archive (centralized S3 log bucket)
                    |
                    +-> security (Security Hub, GuardDuty, Config, Macie, Inspector)
                    +-> network (VPC, TGW, Route53)
                              |
                              +-> shared-services, prod, staging, dev, sandbox
```

## State Isolation

Each account root writes to its own key in the shared S3 state bucket:

| Account         | State Key                          |
|-----------------|------------------------------------|
| management      | `management/terraform.tfstate`     |
| log-archive     | `log-archive/terraform.tfstate`    |
| security        | `security/terraform.tfstate`       |
| network         | `network/terraform.tfstate`        |
| shared-services | `shared-services/terraform.tfstate`|
| prod            | `prod/terraform.tfstate`           |
| staging         | `staging/terraform.tfstate`        |
| dev             | `dev/terraform.tfstate`            |
| sandbox         | `sandbox/terraform.tfstate`        |

Large deployment uses `large/` prefix on all state keys (e.g., `large/management/terraform.tfstate`).

## Cross-Account Data Flow

Accounts read each other's outputs via `terraform_remote_state`:

- `management` reads `log-archive` -> CloudTrail bucket destination
- `security` reads `log-archive` -> Config delivery bucket
- `network` reads `log-archive` -> VPC flow logs bucket
- `prod/staging/dev/sandbox` read `log-archive` + `network` -> log bucket + TGW ID

## IAM Access Pattern

**CI/CD:** GitHub Actions OIDC -> `management` OIDC provider -> `TerraformCIRole` in management -> assume-role into per-account `<org>-<account>-terraform-ci` role.

**Humans:** IAM Identity Center in management -> permission sets assigned per account.

## Network Address Space

| Deployment | Network Account VPC | Workload CIDRs            |
|------------|--------------------|---------------------------|
| medium     | 10.0.0.0/16        | 10.1.0.0/16 - 10.4.0.0/16 |
| large      | 172.16.0.0/16      | 172.17 - 172.23 (/16 each)|
