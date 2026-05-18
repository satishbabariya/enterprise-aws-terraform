# Enterprise AWS Terraform Organization — Design Spec

**Date:** 2026-05-18  
**Status:** Approved  
**Approach:** Account-Centric Root Configs (Native Terraform, no Atmos/Terragrunt)

---

## 1. Goals

Build a production-ready, open-source Terraform template repository that provisions a complete enterprise AWS organization from scratch. The repo ships two reference deployments in the same codebase: one for medium-scale organizations (10–15 accounts) and one for large-scale (30–100+ accounts). All modules are reusable, all accounts are independently deployable, and all four compliance frameworks (CIS AWS Foundations, SOC 2, PCI-DSS, HIPAA) are covered by default.

---

## 2. Constraints & Decisions

| Dimension | Decision |
|---|---|
| Orchestration | Native Terraform only (no Atmos, no Terragrunt) |
| State backend | S3 + DynamoDB, isolated per account |
| Identity | IAM Identity Center (SSO) + GitHub OIDC for CI/CD |
| CI/CD | GitHub Actions |
| Compliance | CIS, SOC 2, PCI-DSS, HIPAA — all four enforced by default |
| Terraform version | >= 1.9 |
| AWS provider version | >= 5.0 |

---

## 3. Repo Structure

```
enterprise-aws-terraform/
│
├── bootstrap/                    # One-time: creates TF state infrastructure
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── modules/                      # Reusable modules (no backend, no state)
│   ├── aws-organization/         # Org, OUs, SCP attachments
│   ├── scp-policies/             # All SCP JSON policies as data sources
│   ├── account-baseline/         # EBS default encryption, IMDSv2, S3 block public, default VPC delete
│   ├── state-backend/            # S3 bucket + DynamoDB for TF state
│   ├── identity-center/          # IAM Identity Center, permission sets, group assignments
│   ├── cloudtrail/               # Org-wide CloudTrail → centralized bucket
│   ├── security-hub/             # Security Hub + CIS/PCI/NIST standards
│   ├── guardduty/                # GuardDuty org-wide delegated admin
│   ├── aws-config/               # Config recorder + conformance packs
│   ├── macie/                    # Macie org-wide
│   ├── access-analyzer/          # IAM Access Analyzer org-wide
│   ├── inspector/                # Inspector v2
│   ├── kms/                      # KMS key per account/purpose with key policies
│   ├── log-archive-bucket/       # Centralized S3 with Object Lock, lifecycle, encryption
│   ├── vpc/                      # VPC, public/private/isolated subnets, flow logs, NACLs
│   ├── tgw-hub/                  # Transit Gateway hub (network account)
│   ├── tgw-spoke/                # TGW attachment + route (workload accounts)
│   ├── route53/                  # Private hosted zones + Resolver inbound/outbound rules
│   └── workload-baseline/        # Composite: account-baseline + KMS + IAM OIDC + budgets
│
├── medium/                       # 10–15 account reference deployment
│   └── accounts/
│       ├── _shared/              # locals.tf (org-wide locals), variables.tf (common vars), backend.tfvars.tmpl, providers.tf.tmpl
│       ├── management/           # Org root, billing, Identity Center, state management
│       ├── security/             # Security Hub delegated admin, GuardDuty master, Config aggregator
│       ├── log-archive/          # Centralized CloudTrail, VPC flow logs, S3 access logs
│       ├── network/              # VPC, TGW hub, Route53 private zones
│       ├── shared-services/      # ECR, internal tooling, ACM
│       ├── prod/
│       ├── staging/
│       ├── dev/
│       └── sandbox/
│
├── large/                        # 30–100+ account reference deployment
│   └── accounts/
│       ├── _shared/              # locals.tf, variables.tf, backend.tfvars.tmpl, providers.tf.tmpl
│       ├── management/
│       ├── security/
│       ├── log-archive/
│       ├── network/
│       ├── shared-services/
│       ├── data-platform/        # Redshift, Glue, Lake Formation
│       ├── security-tools/       # Vulnerability mgmt, CSPM, SOC tooling
│       ├── bu-alpha/
│       │   ├── prod/
│       │   ├── staging/
│       │   └── dev/
│       ├── bu-beta/
│       │   ├── prod/
│       │   ├── staging/
│       │   └── dev/
│       └── account-vending/      # Creates + baselines new accounts on-demand
│
├── .github/
│   └── workflows/
│       ├── plan.yml              # PR: detect changed accounts, run plan in parallel
│       ├── apply.yml             # Merge to main: apply in dependency order
│       └── drift-detect.yml     # Nightly: plan all accounts, open issue on drift
│
├── docs/
│   ├── architecture.md
│   ├── onboarding.md
│   ├── account-vending.md
│   └── compliance-matrix.md
│
├── scripts/
│   ├── bootstrap.sh              # First-time setup wrapper
│   └── new-account.sh            # Scaffold a new account directory from template
│
├── .tflint.hcl
├── .pre-commit-config.yaml       # terraform fmt, validate, tflint, tfsec, checkov
├── .terraform-docs.yaml
└── README.md
```

---

## 4. AWS Account & OU Structure

### Medium Scale

```
Root
├── Security OU
│   ├── management     — Org root, billing, Identity Center, Terraform state mgmt
│   ├── security       — Security Hub delegated admin, GuardDuty master, Config aggregator
│   └── log-archive    — Centralized CloudTrail, VPC flow logs, S3 access logs
├── Infrastructure OU
│   ├── network        — VPC, Transit Gateway hub, Route53 Resolver, DNS
│   └── shared-services — ECR, internal tooling, certificates
└── Workloads OU
    ├── prod
    ├── staging
    ├── dev
    └── sandbox
```

### Large Scale

```
Root
├── Security OU
│   ├── management
│   ├── security
│   ├── log-archive
│   └── security-tools       — CSPM, vulnerability management, SOC tooling
├── Infrastructure OU
│   ├── network
│   ├── shared-services
│   └── data-platform        — Redshift, Glue, Lake Formation
├── Business Units OU
│   ├── bu-alpha OU
│   │   ├── prod / staging / dev
│   └── bu-beta OU
│       ├── prod / staging / dev
└── Suspended OU             — Quarantine for accounts being decommissioned
```

---

## 5. Module Contracts

Every module in `modules/` follows this exact layout:

```
modules/<name>/
├── main.tf        # Resources and data sources only
├── variables.tf   # All inputs: type, description, default, validation
├── outputs.tf     # All outputs consumed by other accounts
├── versions.tf    # required_providers + minimum terraform version
└── README.md      # Auto-generated by terraform-docs
```

**Cross-account data flow** uses native remote state:

```hcl
data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-${var.region}-tfstate"
    key    = "security/terraform.tfstate"
    region = var.region
  }
}
```

Each account root module (`accounts/<name>/`) has:

```
accounts/<name>/
├── backend.tf       # S3 backend declaration
├── providers.tf     # AWS provider + assume_role for this account
├── main.tf          # Module calls
├── variables.tf     # Account-specific variables
├── outputs.tf       # Outputs exposed to other accounts
├── versions.tf      # Provider version pins
└── terraform.tfvars # Account-specific variable values
```

---

## 6. State Management

### Backend per account

```hcl
terraform {
  backend "s3" {
    bucket         = "<org>-<region>-tfstate"
    key            = "<account-name>/terraform.tfstate"
    region         = "<region>"
    dynamodb_table = "<org>-<region>-tfstate-lock"
    encrypt        = true
    kms_key_id     = "<kms-key-arn>"
  }
}
```

### Bootstrap Sequence

1. `cd bootstrap && terraform init && terraform apply` — uses local state, creates S3 bucket + DynamoDB + KMS key in management account
2. `terraform init -migrate-state` — migrates bootstrap's own state to S3
3. All subsequent account roots reference this backend from the start

The `bootstrap/` module is the only module that ever starts with local state.

---

## 7. Security & Compliance

### Service Coverage Matrix

| Layer | Service | CIS | SOC2 | PCI | HIPAA |
|---|---|:---:|:---:|:---:|:---:|
| Preventive | Service Control Policies | ✓ | ✓ | ✓ | ✓ |
| Audit | CloudTrail (org-wide, immutable) | ✓ | ✓ | ✓ | ✓ |
| Threat detection | GuardDuty (org-wide) | ✓ | ✓ | ✓ | ✓ |
| Posture | Security Hub (CIS/PCI/NIST standards) | ✓ | ✓ | ✓ | ✓ |
| Configuration | AWS Config + conformance packs | ✓ | ✓ | ✓ | ✓ |
| Data classification | Macie (org-wide) | — | ✓ | ✓ | ✓ |
| Access analysis | IAM Access Analyzer (org-wide) | ✓ | ✓ | ✓ | ✓ |
| Vulnerability | Inspector v2 (org-wide) | — | ✓ | ✓ | ✓ |
| Encryption | KMS per account, EBS default on, S3 SSE-KMS | ✓ | ✓ | ✓ | ✓ |
| Network audit | VPC flow logs → log-archive | ✓ | ✓ | ✓ | ✓ |

### SCPs (applied at OU level)

| Policy | Scope |
|---|---|
| `deny-root-actions` | All OUs |
| `deny-regions` | All OUs (allowlist approved regions) |
| `deny-leave-org` | All OUs |
| `require-imdsv2` | Workloads OU |
| `deny-s3-public` | Workloads OU + Infrastructure OU |
| `deny-iam-user-creation` | Workloads OU (force Identity Center) |
| `require-encryption-in-transit` | Workloads OU |
| `deny-unencrypted-storage` | Workloads OU |
| `restrict-vpc-changes` | Infrastructure OU |

---

## 8. Identity & Access

- **Humans:** IAM Identity Center in management account. Permission sets: `AdministratorAccess`, `PowerUserAccess`, `ReadOnlyAccess`, `SecurityAudit`, `BillingReadOnly`. Groups mapped to accounts via Identity Center assignments.
- **CI/CD:** GitHub OIDC provider in management account. Each account has a `TerraformCIRole` trusted by the OIDC provider via role chaining from management.
- **Cross-account automation:** Roles assumed via `assume_role` in each account's `providers.tf`.

---

## 9. GitHub Actions Workflows

### `plan.yml` (on PR)
1. Detect which `accounts/*/` directories changed (dorny/paths-filter)
2. Run `terraform plan` for each changed account in parallel matrix
3. Post plan diff as PR comment (terraform-plan-commenter)
4. Block merge if plan fails

### `apply.yml` (on merge to main)
Apply in hard-coded dependency order — sequential, not parallel:
```
management → log-archive → security → network → shared-services → workloads (parallel)
```

### `drift-detect.yml` (nightly cron)
1. Run `terraform plan -detailed-exitcode` across all accounts
2. If exit code 2 (diff detected), open a GitHub Issue with account name + plan output
3. Close the issue automatically on next clean run

---

## 10. Naming & Tagging

### Resource naming pattern
```
${var.org_name}-${var.account_name}-${var.region}-${local.resource_suffix}
```
Example: `acme-prod-us-east-1-vpc`

### Mandatory tags (via provider `default_tags`)

```hcl
default_tags {
  tags = {
    Organization    = var.org_name
    Account         = var.account_name
    Environment     = var.environment          # prod | staging | dev | sandbox
    ManagedBy       = "terraform"
    Repository      = var.repo_url
    CostCenter      = var.cost_center
    DataClass       = var.data_classification  # public | internal | confidential | restricted
    ComplianceScope = var.compliance_scope     # pci | hipaa | soc2 | cis | all
  }
}
```

`DataClass` and `ComplianceScope` are required for PCI-DSS/HIPAA scoping and audit evidence.

---

## 11. Developer Tooling

- **terraform fmt** — enforced in pre-commit and CI
- **tflint** — module-level linting with AWS ruleset
- **tfsec / checkov** — static security analysis in CI
- **terraform-docs** — auto-generates `modules/*/README.md` from variables/outputs
- **`scripts/new-account.sh`** — scaffolds a new account directory from the `_shared/` template, prompts for account name, ID, environment, and generates `backend.tf`, `providers.tf`, `terraform.tfvars`

---

## 12. What This Repo Does NOT Include

- Application-level resources (RDS instances, EKS clusters, Lambda functions) — those belong in workload repos
- Terraform Cloud / HCP Terraform configuration
- Multi-region active-active networking (TGW is single-region; multi-region extension is a follow-on)
- Billing anomaly detection (covered by AWS Budgets alerts in `workload-baseline`, not a separate module)
