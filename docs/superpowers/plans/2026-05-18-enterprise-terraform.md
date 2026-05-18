# Enterprise AWS Terraform Organization — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete enterprise AWS organization Terraform template repo — reusable module library, medium (10-account) and large (30+ account) reference deployments, GitHub Actions CI/CD — covering CIS, SOC2, PCI-DSS, and HIPAA compliance by default.

**Architecture:** Account-centric root configs with a shared reusable modules library in `modules/`. Each AWS account is an independent Terraform root module with its own S3+DynamoDB state. Cross-account data flows via `terraform_remote_state`. Two complete reference deployments live side-by-side under `medium/` and `large/`.

**Tech Stack:** Terraform >= 1.9, AWS Provider >= 5.0, GitHub Actions, S3+DynamoDB state, IAM Identity Center, GitHub OIDC

**Phase map — stop cleanly at any boundary:**
- Phase 1 (Tasks 1–2): Repo scaffolding + tooling
- Phase 2 (Task 3): Bootstrap (state infrastructure)
- Phase 3 (Tasks 4–8): Foundation modules (org, SCPs, state-backend, KMS, account-baseline)
- Phase 4 (Tasks 9–15): Security modules (log-archive, cloudtrail, security-hub, guardduty, config, macie, access-analyzer, inspector)
- Phase 5 (Tasks 16–21): Identity & networking modules (identity-center, vpc, tgw-hub, tgw-spoke, route53, workload-baseline)
- Phase 6 (Tasks 22–28): Medium deployment (all 10 accounts)
- Phase 7 (Tasks 29–33): Large deployment (additional accounts + account-vending)
- Phase 8 (Tasks 34–37): GitHub Actions workflows + scripts + docs

---

## Phase 1: Repo Scaffolding & Developer Tooling

### Task 1: Initialize repo structure and tooling config

**Files:**
- Create: `README.md`
- Create: `.gitignore`
- Create: `.tflint.hcl`
- Create: `.pre-commit-config.yaml`
- Create: `.terraform-docs.yaml`
- Create: `modules/.gitkeep`
- Create: `medium/accounts/.gitkeep`
- Create: `large/accounts/.gitkeep`
- Create: `bootstrap/.gitkeep`
- Create: `scripts/.gitkeep`
- Create: `docs/.gitkeep`
- Create: `.github/workflows/.gitkeep`

- [ ] **Step 1: Create directory skeleton**

```bash
mkdir -p modules bootstrap scripts docs/.gitkeep \
  medium/accounts large/accounts \
  .github/workflows \
  docs/superpowers/specs docs/superpowers/plans
touch modules/.gitkeep medium/accounts/.gitkeep large/accounts/.gitkeep \
  bootstrap/.gitkeep scripts/.gitkeep .github/workflows/.gitkeep
```

- [ ] **Step 2: Create `.gitignore`**

```
# Terraform
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.backup
*.tfplan
*.tfplan.json
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# Secrets
*.pem
*.key
secrets.tfvars
*secrets*.tfvars
.env

# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
```

- [ ] **Step 3: Create `.tflint.hcl`**

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}
```

- [ ] **Step 4: Create `.pre-commit-config.yaml`**

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.96.1
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      - id: terraform_docs
        args:
          - --args=--config=.terraform-docs.yaml
      - id: checkov
        args:
          - --args=--quiet
          - --args=--compact

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-merge-conflict
      - id: detect-private-key
```

- [ ] **Step 5: Create `.terraform-docs.yaml`**

```yaml
formatter: markdown table
version: ""
header-from: main.tf
footer-from: ""
recursive:
  enabled: false
sections:
  hide: []
  show: []
content: |-
  {{ .Header }}

  ## Requirements

  {{ .Requirements }}

  ## Providers

  {{ .Providers }}

  ## Inputs

  {{ .Inputs }}

  ## Outputs

  {{ .Outputs }}
output:
  file: README.md
  mode: replace
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
sort:
  enabled: true
  by: name
settings:
  anchor: true
  color: true
  default: true
  description: true
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 6: Create top-level `README.md`**

```markdown
# Enterprise AWS Terraform Organization

Production-ready Terraform template for a complete enterprise AWS organization.
Covers CIS AWS Foundations, SOC 2, PCI-DSS, and HIPAA compliance by default.

## What's included

- **`modules/`** — 18 reusable Terraform modules (no state)
- **`medium/`** — 10-account reference deployment
- **`large/`** — 30+ account reference deployment
- **`bootstrap/`** — One-time state infrastructure setup
- **`.github/workflows/`** — GitHub Actions CI/CD (plan on PR, apply on merge, nightly drift detection)

## Prerequisites

- Terraform >= 1.9
- AWS CLI configured with management account credentials
- GitHub repository (for OIDC trust)

## First-time setup

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your org name, region, management account ID
terraform init
terraform apply
terraform init -migrate-state  # migrate bootstrap state to S3
```

## Deploying accounts

Each account under `medium/accounts/<name>/` or `large/accounts/<name>/` is an
independent Terraform root. Deploy in dependency order:

```
management → log-archive → security → network → shared-services → workloads
```

See `docs/architecture.md` for full dependency graph.
```

- [ ] **Step 7: Commit**

```bash
git init
git add .
git commit -m "chore: initialize repo structure and developer tooling"
```

---

### Task 2: Define shared module conventions file

Every module in `modules/` follows the same `versions.tf` and provider pattern. Create it once here so Tasks 4–21 can reference it directly.

**Files:**
- Create: `modules/_template/versions.tf`
- Create: `modules/_template/variables.tf`
- Create: `modules/_template/outputs.tf`
- Create: `modules/_template/main.tf`

- [ ] **Step 1: Create template `versions.tf`** (copy this into every new module)

```hcl
terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

- [ ] **Step 2: Create template `variables.tf` preamble** (every module starts with these)

```hcl
variable "org_name" {
  description = "Short lowercase name for the organization, used in resource naming. Example: acme"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be 2-21 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "region" {
  description = "AWS region for resources. Example: us-east-1"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/_template/
git commit -m "chore: add module template conventions"
```

---

## Phase 2: Bootstrap

### Task 3: Bootstrap module (state S3 + DynamoDB + KMS)

Run once manually from a terminal with management account credentials. Creates the S3 bucket and DynamoDB table that all subsequent account state files will use.

**Files:**
- Create: `bootstrap/main.tf`
- Create: `bootstrap/variables.tf`
- Create: `bootstrap/outputs.tf`
- Create: `bootstrap/versions.tf`
- Create: `bootstrap/terraform.tfvars.example`
- Create: `bootstrap/backend.tf` (initially commented out — enabled after migration)

- [ ] **Step 1: Write `bootstrap/versions.tf`**

```hcl
terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Repository  = var.repo_url
      Environment = "management"
      Account     = "management"
    }
  }
}
```

- [ ] **Step 2: Write `bootstrap/variables.tf`**

```hcl
variable "org_name" {
  description = "Short lowercase org name used in bucket naming. Example: acme"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be lowercase alphanumeric + hyphens."
  }
}

variable "region" {
  description = "AWS region for the state bucket and DynamoDB table."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL, used in resource tags. Example: https://github.com/acme/infra"
  type        = string
}

variable "management_account_id" {
  description = "AWS account ID of the management account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "management_account_id must be a 12-digit AWS account ID."
  }
}
```

- [ ] **Step 3: Write `bootstrap/main.tf`**

```hcl
locals {
  bucket_name = "${var.org_name}-${var.region}-tfstate"
  table_name  = "${var.org_name}-${var.region}-tfstate-lock"
  kms_alias   = "alias/${var.org_name}-tfstate"
}

resource "aws_kms_key" "tfstate" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.management_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "tfstate" {
  name          = local.kms_alias
  target_key_id = aws_kms_key.tfstate.key_id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.tfstate.id
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}
```

- [ ] **Step 4: Write `bootstrap/outputs.tf`**

```hcl
output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform state"
  value       = aws_s3_bucket.tfstate.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "kms_key_arn" {
  description = "KMS key ARN used to encrypt state"
  value       = aws_kms_key.tfstate.arn
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.tfstate.name
}
```

- [ ] **Step 5: Write `bootstrap/terraform.tfvars.example`**

```hcl
org_name              = "acme"
region                = "us-east-1"
repo_url              = "https://github.com/acme/enterprise-aws-terraform"
management_account_id = "123456789012"
```

- [ ] **Step 6: Write `bootstrap/backend.tf`** (disabled initially, enable after migration)

```hcl
# Uncomment after running: terraform init -migrate-state
#
# terraform {
#   backend "s3" {
#     bucket         = "<org_name>-<region>-tfstate"
#     key            = "bootstrap/terraform.tfstate"
#     region         = "<region>"
#     dynamodb_table = "<org_name>-<region>-tfstate-lock"
#     encrypt        = true
#   }
# }
```

- [ ] **Step 7: Validate**

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with real values
terraform init
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 8: Commit**

```bash
git add bootstrap/
git commit -m "feat: add bootstrap module for state infrastructure"
```

---

## Phase 3: Foundation Modules

### Task 4: `modules/aws-organization`

Creates the AWS Organization, enables trusted services, creates OUs, and attaches SCPs. Called only from the management account root.

**Files:**
- Create: `modules/aws-organization/main.tf`
- Create: `modules/aws-organization/variables.tf`
- Create: `modules/aws-organization/outputs.tf`
- Create: `modules/aws-organization/versions.tf`
- Create: `modules/aws-organization/tests/organization.tftest.hcl`

- [ ] **Step 1: Write `modules/aws-organization/versions.tf`**

```hcl
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

- [ ] **Step 2: Write `modules/aws-organization/variables.tf`**

```hcl
variable "org_name" {
  description = "Short lowercase org name. Example: acme"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be lowercase alphanumeric + hyphens."
  }
}

variable "organizational_units" {
  description = <<-EOT
    Map of OUs to create. Each entry: { name = string, parent_key = string }.
    Use parent_key = "root" to attach directly to the org root.
    Use the map key of another OU to nest under it.
  EOT
  type = map(object({
    name       = string
    parent_key = string
  }))
  default = {
    security       = { name = "Security",       parent_key = "root" }
    infrastructure = { name = "Infrastructure", parent_key = "root" }
    workloads      = { name = "Workloads",      parent_key = "root" }
    suspended      = { name = "Suspended",      parent_key = "root" }
  }
}

variable "enabled_policy_types" {
  description = "Organization policy types to enable."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
}

variable "tags" {
  description = "Tags to apply to taggable org resources."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 3: Write `modules/aws-organization/main.tf`**

```hcl
resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "guardduty.amazonaws.com",
    "inspector2.amazonaws.com",
    "macie.amazonaws.com",
    "securityhub.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]
  feature_set          = "ALL"
  enabled_policy_types = var.enabled_policy_types
}

locals {
  root_id = aws_organizations_organization.this.roots[0].id

  # Build a map that resolves parent_key to real parent_id for each OU.
  # Two-pass: first pass resolves "root", second pass resolves sibling keys.
  # All OUs in this module are max 2 levels deep (root → OU).
  # Deeper nesting requires chaining module calls in the caller.
  ou_parent_ids = {
    for key, ou in var.organizational_units :
    key => ou.parent_key == "root" ? local.root_id : aws_organizations_organizational_unit.this[ou.parent_key].id
  }
}

resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value.name
  parent_id = each.value.parent_key == "root" ? local.root_id : aws_organizations_organizational_unit.this[each.value.parent_key].id

  tags = var.tags

  depends_on = [aws_organizations_organization.this]
}
```

- [ ] **Step 4: Write `modules/aws-organization/outputs.tf`**

```hcl
output "organization_id" {
  description = "AWS Organizations organization ID"
  value       = aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "AWS Organizations organization ARN"
  value       = aws_organizations_organization.this.arn
}

output "master_account_id" {
  description = "Management account ID"
  value       = aws_organizations_organization.this.master_account_id
}

output "root_id" {
  description = "Organization root ID"
  value       = aws_organizations_organization.this.roots[0].id
}

output "organizational_unit_ids" {
  description = "Map of OU key to OU ID"
  value       = { for k, v in aws_organizations_organizational_unit.this : k => v.id }
}

output "organizational_unit_arns" {
  description = "Map of OU key to OU ARN"
  value       = { for k, v in aws_organizations_organizational_unit.this : k => v.arn }
}
```

- [ ] **Step 5: Write test `modules/aws-organization/tests/organization.tftest.hcl`**

```hcl
mock_provider "aws" {}

variables {
  org_name = "testorg"
}

run "default_ous_are_created" {
  command = plan

  assert {
    condition     = length(aws_organizations_organizational_unit.this) == 4
    error_message = "Expected 4 default OUs (Security, Infrastructure, Workloads, Suspended)"
  }

  assert {
    condition     = aws_organizations_organization.this.feature_set == "ALL"
    error_message = "Organization must use ALL features"
  }
}

run "custom_ous" {
  command = plan

  variables {
    organizational_units = {
      bu_one = { name = "BU-One", parent_key = "root" }
      bu_two = { name = "BU-Two", parent_key = "root" }
    }
  }

  assert {
    condition     = length(aws_organizations_organizational_unit.this) == 2
    error_message = "Expected exactly 2 OUs for custom config"
  }
}
```

- [ ] **Step 6: Run test**

```bash
cd modules/aws-organization
terraform init
terraform test
```

Expected: `2 passed, 0 failed`

- [ ] **Step 7: Validate**

```bash
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 8: Commit**

```bash
git add modules/aws-organization/
git commit -m "feat: add aws-organization module"
```

---

### Task 5: `modules/scp-policies`

Creates all Service Control Policies as `aws_organizations_policy` resources. Policies are defined inline as HCL-encoded JSON. The caller attaches them to OUs using `aws_organizations_policy_attachment` (done in the management account root, not this module).

**Files:**
- Create: `modules/scp-policies/main.tf`
- Create: `modules/scp-policies/variables.tf`
- Create: `modules/scp-policies/outputs.tf`
- Create: `modules/scp-policies/versions.tf`
- Create: `modules/scp-policies/tests/scps.tftest.hcl`

- [ ] **Step 1: Write `modules/scp-policies/versions.tf`**

Same as Task 4 Step 1 — copy verbatim.

- [ ] **Step 2: Write `modules/scp-policies/variables.tf`**

```hcl
variable "allowed_regions" {
  description = "List of AWS regions to allow. All other regions are denied."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "tags" {
  description = "Tags for SCP resources."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 3: Write `modules/scp-policies/main.tf`**

```hcl
resource "aws_organizations_policy" "deny_root_actions" {
  name        = "DenyRootActions"
  description = "Deny all actions by the root user"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyRootActions"
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
      Condition = {
        StringLike = {
          "aws:PrincipalArn" = ["arn:aws:iam::*:root"]
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyLeaveOrg"
      Effect   = "Deny"
      Action   = ["organizations:LeaveOrganization"]
      Resource = "*"
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyNonApprovedRegions"
  description = "Deny all actions outside approved regions (except global services)"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyNonApprovedRegions"
      Effect = "Deny"
      NotAction = [
        "a4b:*", "acm:*", "aws-marketplace-management:*", "aws-marketplace:*",
        "aws-portal:*", "budgets:*", "ce:*", "chime:*", "cloudfront:*",
        "config:*", "cur:*", "directconnect:*", "ec2:DescribeRegions",
        "ec2:DescribeTransitGateways", "ecr-public:*", "globalaccelerator:*",
        "health:*", "iam:*", "importexport:*", "kms:*", "mobileanalytics:*",
        "networkmanager:*", "organizations:*", "pricing:*", "route53:*",
        "route53domains:*", "s3:GetAccountPublic*", "s3:ListAllMyBuckets",
        "s3:PutAccountPublic*", "shield:*", "sts:*", "support:*",
        "trustedadvisor:*", "waf-regional:*", "waf:*", "wafv2:*",
        "wellarchitected:*"
      ]
      Resource = "*"
      Condition = {
        StringNotIn = {
          "aws:RequestedRegion" = var.allowed_regions
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "require_imdsv2" {
  name        = "RequireIMDSv2"
  description = "Deny EC2 RunInstances if IMDSv2 is not required"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "RequireIMDSv2"
      Effect = "Deny"
      Action = ["ec2:RunInstances"]
      Resource = "arn:aws:ec2:*:*:instance/*"
      Condition = {
        StringNotEquals = {
          "ec2:MetadataHttpTokens" = "required"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_s3_public" {
  name        = "DenyS3PublicAccess"
  description = "Deny disabling S3 Block Public Access at account or bucket level"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyS3PublicAccess"
      Effect = "Deny"
      Action = [
        "s3:PutBucketPublicAccessBlock",
        "s3:PutAccountPublicAccessBlock"
      ]
      Resource = "*"
      Condition = {
        StringEquals = {
          "s3:PublicAccessBlockConfiguration/BlockPublicAcls"       = "false"
          "s3:PublicAccessBlockConfiguration/BlockPublicPolicy"     = "false"
          "s3:PublicAccessBlockConfiguration/IgnorePublicAcls"      = "false"
          "s3:PublicAccessBlockConfiguration/RestrictPublicBuckets" = "false"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_iam_user_creation" {
  name        = "DenyIAMUserCreation"
  description = "Deny creation of IAM users — force use of Identity Center"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyIAMUserCreation"
      Effect   = "Deny"
      Action   = ["iam:CreateUser", "iam:CreateAccessKey"]
      Resource = "*"
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_unencrypted_storage" {
  name        = "DenyUnencryptedStorage"
  description = "Deny creation of unencrypted EBS volumes, RDS instances, and S3 buckets"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedEBS"
        Effect = "Deny"
        Action = ["ec2:CreateVolume"]
        Resource = "*"
        Condition = {
          Bool = { "ec2:Encrypted" = "false" }
        }
      },
      {
        Sid    = "DenyUnencryptedRDS"
        Effect = "Deny"
        Action = ["rds:CreateDBInstance"]
        Resource = "*"
        Condition = {
          Bool = { "rds:StorageEncrypted" = "false" }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_vpc_changes" {
  name        = "DenyVPCChanges"
  description = "Deny modification of VPC infrastructure in workload accounts (networking managed centrally)"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyVPCChanges"
      Effect = "Deny"
      Action = [
        "ec2:CreateVpc", "ec2:DeleteVpc",
        "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
        "ec2:CreateSubnet", "ec2:DeleteSubnet",
        "ec2:ModifyVpcAttribute"
      ]
      Resource = "*"
    }]
  })

  tags = var.tags
}
```

- [ ] **Step 4: Write `modules/scp-policies/outputs.tf`**

```hcl
output "policy_ids" {
  description = "Map of SCP name to policy ID"
  value = {
    deny_root_actions        = aws_organizations_policy.deny_root_actions.id
    deny_leave_org           = aws_organizations_policy.deny_leave_org.id
    deny_regions             = aws_organizations_policy.deny_regions.id
    require_imdsv2           = aws_organizations_policy.require_imdsv2.id
    deny_s3_public           = aws_organizations_policy.deny_s3_public.id
    deny_iam_user_creation   = aws_organizations_policy.deny_iam_user_creation.id
    deny_unencrypted_storage = aws_organizations_policy.deny_unencrypted_storage.id
    deny_vpc_changes         = aws_organizations_policy.deny_vpc_changes.id
  }
}
```

- [ ] **Step 5: Write test `modules/scp-policies/tests/scps.tftest.hcl`**

```hcl
mock_provider "aws" {}

variables {}

run "all_policies_planned" {
  command = plan

  assert {
    condition     = aws_organizations_policy.deny_root_actions.type == "SERVICE_CONTROL_POLICY"
    error_message = "deny_root_actions must be a SERVICE_CONTROL_POLICY"
  }

  assert {
    condition     = aws_organizations_policy.deny_leave_org.type == "SERVICE_CONTROL_POLICY"
    error_message = "deny_leave_org must be a SERVICE_CONTROL_POLICY"
  }

  assert {
    condition     = aws_organizations_policy.deny_iam_user_creation.type == "SERVICE_CONTROL_POLICY"
    error_message = "deny_iam_user_creation must be a SERVICE_CONTROL_POLICY"
  }
}

run "custom_allowed_regions" {
  command = plan

  variables {
    allowed_regions = ["eu-west-1", "eu-central-1"]
  }

  assert {
    condition     = can(jsondecode(aws_organizations_policy.deny_regions.content))
    error_message = "deny_regions policy content must be valid JSON"
  }
}
```

- [ ] **Step 6: Run test**

```bash
cd modules/scp-policies && terraform init && terraform test
```

Expected: `2 passed, 0 failed`

- [ ] **Step 7: Commit**

```bash
git add modules/scp-policies/
git commit -m "feat: add scp-policies module (8 SCPs)"
```

---

### Task 6: `modules/kms`

Single-purpose KMS key with rotation, configurable key policy. Used by every account for encrypting state, EBS, S3, RDS, etc.

**Files:**
- Create: `modules/kms/main.tf`
- Create: `modules/kms/variables.tf`
- Create: `modules/kms/outputs.tf`
- Create: `modules/kms/versions.tf`
- Create: `modules/kms/tests/kms.tftest.hcl`

- [ ] **Step 1: Write `modules/kms/variables.tf`**

```hcl
variable "account_id" {
  description = "AWS account ID that owns this key."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "description" {
  description = "Human-readable description of what this key encrypts."
  type        = string
}

variable "key_alias" {
  description = "KMS alias (without 'alias/' prefix). Example: acme-prod-ebs"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Days before key deletion after destroy. Between 7 and 30."
  type        = number
  default     = 30
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "additional_key_admins" {
  description = "List of IAM ARNs that can administer (but not use) this key."
  type        = list(string)
  default     = []
}

variable "additional_key_users" {
  description = "List of IAM ARNs that can use this key for encrypt/decrypt."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the KMS key."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 2: Write `modules/kms/main.tf`**

```hcl
data "aws_iam_policy_document" "key_policy" {
  statement {
    sid     = "EnableRootAccess"
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.additional_key_admins) > 0 ? [1] : []
    content {
      sid    = "KeyAdministrators"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.additional_key_admins
      }
      actions = [
        "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*",
        "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*",
        "kms:Get*", "kms:Delete*", "kms:TagResource", "kms:UntagResource",
        "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.additional_key_users) > 0 ? [1] : []
    content {
      sid    = "KeyUsers"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.additional_key_users
      }
      actions = [
        "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
        "kms:GenerateDataKey*", "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.key_policy.json

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.this.key_id
}
```

- [ ] **Step 3: Write `modules/kms/outputs.tf`**

```hcl
output "key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "KMS alias name (including alias/ prefix)"
  value       = aws_kms_alias.this.name
}

output "alias_arn" {
  description = "KMS alias ARN"
  value       = aws_kms_alias.this.arn
}
```

- [ ] **Step 4: Write `modules/kms/versions.tf`** — same as Task 4 Step 1, copy verbatim.

- [ ] **Step 5: Write test `modules/kms/tests/kms.tftest.hcl`**

```hcl
mock_provider "aws" {}

variables {
  account_id   = "123456789012"
  description  = "Test KMS key"
  key_alias    = "testorg-prod-ebs"
}

run "key_rotation_enabled" {
  command = plan

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "Key rotation must be enabled"
  }
}

run "alias_has_prefix" {
  command = plan

  assert {
    condition     = startswith(aws_kms_alias.this.name, "alias/")
    error_message = "KMS alias must start with 'alias/'"
  }
}

run "deletion_window_validation" {
  command = plan

  variables {
    deletion_window_in_days = 14
  }

  assert {
    condition     = aws_kms_key.this.deletion_window_in_days == 14
    error_message = "Custom deletion window should be accepted"
  }
}
```

- [ ] **Step 6: Run test**

```bash
cd modules/kms && terraform init && terraform test
```

Expected: `3 passed, 0 failed`

- [ ] **Step 7: Commit**

```bash
git add modules/kms/
git commit -m "feat: add kms module"
```

---

### Task 7: `modules/state-backend`

Creates the per-account S3 state bucket and DynamoDB lock table. Called from each account's root module during initial account setup.

**Files:**
- Create: `modules/state-backend/main.tf`
- Create: `modules/state-backend/variables.tf`
- Create: `modules/state-backend/outputs.tf`
- Create: `modules/state-backend/versions.tf`

- [ ] **Step 1: Write `modules/state-backend/variables.tf`**

```hcl
variable "org_name" {
  description = "Short lowercase org name. Example: acme"
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name. Example: prod"
  type        = string
}

variable "region" {
  description = "AWS region for the bucket and table."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt the state bucket and DynamoDB table."
  type        = string
}

variable "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket for S3 access logging."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 2: Write `modules/state-backend/main.tf`**

```hcl
locals {
  bucket_name = "${var.org_name}-${var.account_name}-${var.region}-tfstate"
  table_name  = "${var.org_name}-${var.account_name}-${var.region}-tfstate-lock"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
  lifecycle { prevent_destroy = true }
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = var.log_archive_bucket_arn
  target_prefix = "s3-access-logs/${local.bucket_name}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    noncurrent_version_expiration { noncurrent_days = 90 }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery { enabled = true }

  tags = var.tags
}
```

- [ ] **Step 3: Write `modules/state-backend/outputs.tf`**

```hcl
output "bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.tfstate.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.lock.name
}
```

- [ ] **Step 4: Write `modules/state-backend/versions.tf`** — same as Task 4 Step 1, copy verbatim.

- [ ] **Step 5: Validate**

```bash
cd modules/state-backend && terraform init && terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add modules/state-backend/
git commit -m "feat: add state-backend module"
```

---

### Task 8: `modules/account-baseline`

Applies account-level security hardening to any AWS account: deletes the default VPC, enables EBS encryption by default, requires IMDSv2, and blocks S3 public access at the account level.

**Files:**
- Create: `modules/account-baseline/main.tf`
- Create: `modules/account-baseline/variables.tf`
- Create: `modules/account-baseline/outputs.tf`
- Create: `modules/account-baseline/versions.tf`
- Create: `modules/account-baseline/tests/baseline.tftest.hcl`

- [ ] **Step 1: Write `modules/account-baseline/variables.tf`**

```hcl
variable "account_id" {
  description = "AWS account ID of the account being baselined."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Must be a 12-digit AWS account ID."
  }
}

variable "regions" {
  description = "All AWS regions to apply EBS default encryption and delete default VPCs in."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "delete_default_vpc" {
  description = "If true, delete the default VPC in all specified regions."
  type        = bool
  default     = true
}

variable "iam_account_password_policy" {
  description = "IAM account password policy settings."
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers                = bool
    require_symbols                = bool
    allow_users_to_change_password = bool
    max_password_age               = number
    password_reuse_prevention      = number
    hard_expiry                    = bool
  })
  default = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
    hard_expiry                    = false
  }
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
```

- [ ] **Step 2: Write `modules/account-baseline/main.tf`**

```hcl
# EBS default encryption per region
resource "aws_ebs_encryption_by_default" "this" {
  for_each = toset(var.regions)

  provider = aws.region[each.key]
  enabled  = true
}

# S3 public access block at account level
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM password policy (CIS 1.x)
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.iam_account_password_policy.minimum_password_length
  require_lowercase_characters   = var.iam_account_password_policy.require_lowercase_characters
  require_uppercase_characters   = var.iam_account_password_policy.require_uppercase_characters
  require_numbers                = var.iam_account_password_policy.require_numbers
  require_symbols                = var.iam_account_password_policy.require_symbols
  allow_users_to_change_password = var.iam_account_password_policy.allow_users_to_change_password
  max_password_age               = var.iam_account_password_policy.max_password_age
  password_reuse_prevention      = var.iam_account_password_policy.password_reuse_prevention
  hard_expiry                    = var.iam_account_password_policy.hard_expiry
}

# Budget alert (baseline: $50 notification per account)
resource "aws_budgets_budget" "monthly" {
  name              = "monthly-budget-alert"
  budget_type       = "COST"
  limit_amount      = "50"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = []
  }
}
```

**Note:** `aws_ebs_encryption_by_default` requires provider aliases per region. The caller must configure provider aliases. The account-baseline module uses `for_each` over a provider alias map. For simplicity in the medium deployment, call this module once per region explicitly. See `medium/accounts/_shared/locals.tf` in Task 22 for the provider alias setup.

- [ ] **Step 3: Simplify to single-region variant** (the multi-region expansion happens in each account root; keep the module single-region, call it N times from the root)

Replace the `main.tf` content above with the single-region version:

```hcl
# S3 public access block at account level (region-agnostic)
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# EBS default encryption (applied to the provider's configured region)
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

# IMDSv2 enforcement via EC2 instance metadata defaults
resource "aws_ec2_instance_metadata_defaults" "this" {
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
  instance_metadata_tags      = "enabled"
}

# IAM account password policy
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.iam_account_password_policy.minimum_password_length
  require_lowercase_characters   = var.iam_account_password_policy.require_lowercase_characters
  require_uppercase_characters   = var.iam_account_password_policy.require_uppercase_characters
  require_numbers                = var.iam_account_password_policy.require_numbers
  require_symbols                = var.iam_account_password_policy.require_symbols
  allow_users_to_change_password = var.iam_account_password_policy.allow_users_to_change_password
  max_password_age               = var.iam_account_password_policy.max_password_age
  password_reuse_prevention      = var.iam_account_password_policy.password_reuse_prevention
  hard_expiry                    = var.iam_account_password_policy.hard_expiry
}

resource "aws_budgets_budget" "monthly" {
  name         = "monthly-budget-alert"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = []
  }
}
```

- [ ] **Step 4: Write `modules/account-baseline/outputs.tf`**

```hcl
output "s3_public_access_block_id" {
  description = "ID of the S3 account public access block"
  value       = aws_s3_account_public_access_block.this.id
}
```

- [ ] **Step 5: Write `modules/account-baseline/versions.tf`** — copy from Task 4 Step 1 verbatim.

- [ ] **Step 6: Write test `modules/account-baseline/tests/baseline.tftest.hcl`**

```hcl
mock_provider "aws" {}

variables {
  account_id = "123456789012"
}

run "s3_public_access_blocked" {
  command = plan

  assert {
    condition     = aws_s3_account_public_access_block.this.block_public_acls == true
    error_message = "block_public_acls must be true"
  }

  assert {
    condition     = aws_s3_account_public_access_block.this.restrict_public_buckets == true
    error_message = "restrict_public_buckets must be true"
  }
}

run "imdsv2_required" {
  command = plan

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this.http_tokens == "required"
    error_message = "IMDSv2 must be required"
  }
}

run "password_policy_minimum_length" {
  command = plan

  assert {
    condition     = aws_iam_account_password_policy.this.minimum_password_length >= 14
    error_message = "Password minimum length must be >= 14 (CIS 1.8)"
  }
}
```

- [ ] **Step 7: Run test**

```bash
cd modules/account-baseline && terraform init && terraform test
```

Expected: `3 passed, 0 failed`

- [ ] **Step 8: Commit**

```bash
git add modules/account-baseline/
git commit -m "feat: add account-baseline module (CIS 1.x controls)"
```

---

## Phase 4: Security Modules

### Task 9: `modules/log-archive-bucket`

Centralized S3 bucket in the log-archive account. Receives CloudTrail, VPC flow logs, S3 access logs, Config snapshots. S3 Object Lock (WORM) ensures immutability for compliance.

**Files:**
- Create: `modules/log-archive-bucket/main.tf`
- Create: `modules/log-archive-bucket/variables.tf`
- Create: `modules/log-archive-bucket/outputs.tf`
- Create: `modules/log-archive-bucket/versions.tf`

- [ ] **Step 1: Write `modules/log-archive-bucket/variables.tf`**

```hcl
variable "org_name" {
  type        = string
  description = "Short lowercase org name."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "org_id" {
  type        = string
  description = "AWS Organizations organization ID. Used to scope the bucket policy."
}

variable "management_account_id" {
  type        = string
  description = "Management account ID — allowed to read and manage the bucket."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for bucket encryption."
}

variable "object_lock_retention_days" {
  type        = number
  description = "WORM retention period in days. Minimum 365 for PCI-DSS/HIPAA."
  default     = 365
  validation {
    condition     = var.object_lock_retention_days >= 365
    error_message = "Retention must be at least 365 days for PCI-DSS and HIPAA compliance."
  }
}

variable "log_prefixes" {
  type        = list(string)
  description = "S3 prefixes that will receive logs. Used for lifecycle rules."
  default     = ["cloudtrail/", "vpc-flow-logs/", "config/", "s3-access-logs/"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

- [ ] **Step 2: Write `modules/log-archive-bucket/main.tf`**

```hcl
locals {
  bucket_name = "${var.org_name}-${var.region}-log-archive"
}

resource "aws_s3_bucket" "logs" {
  bucket              = local.bucket_name
  object_lock_enabled = true
  lifecycle { prevent_destroy = true }
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_object_lock_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.object_lock_retention_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    sid    = "DenyNonSecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowOrgCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/cloudtrail/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [var.org_id]
    }
  }

  statement {
    sid    = "AllowCloudTrailGetBucketAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]
  }

  statement {
    sid    = "AllowConfigWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject", "s3:GetBucketAcl"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/config/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [var.org_id]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_bucket_policy.json
}
```

- [ ] **Step 3: Write `modules/log-archive-bucket/outputs.tf`**

```hcl
output "bucket_name" { value = aws_s3_bucket.logs.bucket }
output "bucket_arn"  { value = aws_s3_bucket.logs.arn }
output "bucket_id"   { value = aws_s3_bucket.logs.id }
```

- [ ] **Step 4: Write `modules/log-archive-bucket/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate**

```bash
cd modules/log-archive-bucket && terraform init && terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add modules/log-archive-bucket/
git commit -m "feat: add log-archive-bucket module (WORM, Object Lock)"
```

---

### Task 10: `modules/cloudtrail`

Organization-wide CloudTrail trail in the management account, writing to the log-archive bucket. Multi-region, log file validation, data events for S3 and Lambda.

**Files:**
- Create: `modules/cloudtrail/main.tf`
- Create: `modules/cloudtrail/variables.tf`
- Create: `modules/cloudtrail/outputs.tf`
- Create: `modules/cloudtrail/versions.tf`

- [ ] **Step 1: Write `modules/cloudtrail/variables.tf`**

```hcl
variable "org_name"                 { type = string }
variable "log_archive_bucket_name"  { type = string; description = "Name of the centralized log-archive S3 bucket." }
variable "kms_key_arn"              { type = string; description = "KMS key ARN for CloudTrail log encryption." }
variable "cloudwatch_log_group_arn" { type = string; description = "CloudWatch Logs group ARN for CloudTrail delivery." default = "" }
variable "tags"                     { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/cloudtrail/main.tf`**

```hcl
resource "aws_iam_role" "cloudtrail_cw" {
  name = "${var.org_name}-cloudtrail-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudtrail_cw" {
  name   = "cloudtrail-cw-policy"
  role   = aws_iam_role.cloudtrail_cw.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${var.cloudwatch_log_group_arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "org" {
  name                          = "${var.org_name}-org-trail"
  s3_bucket_name                = var.log_archive_bucket_name
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  cloud_watch_logs_group_arn    = var.cloudwatch_log_group_arn != "" ? "${var.cloudwatch_log_group_arn}:*" : null
  cloud_watch_logs_role_arn     = var.cloudwatch_log_group_arn != "" ? aws_iam_role.cloudtrail_cw.arn : null

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = var.tags
}
```

- [ ] **Step 3: Write `modules/cloudtrail/outputs.tf`**

```hcl
output "trail_arn"  { value = aws_cloudtrail.org.arn }
output "trail_name" { value = aws_cloudtrail.org.name }
```

- [ ] **Step 4: Write `modules/cloudtrail/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate**

```bash
cd modules/cloudtrail && terraform init && terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add modules/cloudtrail/
git commit -m "feat: add cloudtrail module (org-wide, multi-region, log validation)"
```

---

### Task 11: `modules/security-hub`

Security Hub in the delegated admin (security) account, with CIS AWS Foundations v3.0, PCI-DSS, and NIST standards enabled org-wide.

**Files:**
- Create: `modules/security-hub/main.tf`
- Create: `modules/security-hub/variables.tf`
- Create: `modules/security-hub/outputs.tf`
- Create: `modules/security-hub/versions.tf`

- [ ] **Step 1: Write `modules/security-hub/variables.tf`**

```hcl
variable "enable_cis_standard"   { type = bool; default = true; description = "Enable CIS AWS Foundations Benchmark v3.0" }
variable "enable_pci_standard"   { type = bool; default = true; description = "Enable PCI-DSS v3.2.1" }
variable "enable_nist_standard"  { type = bool; default = true; description = "Enable NIST SP 800-53 Rev 5" }
variable "auto_enable_new_accounts" { type = bool; default = true; description = "Auto-enable Security Hub for new org accounts." }
variable "tags"                  { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/security-hub/main.tf`**

```hcl
resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = var.auto_enable_new_accounts
  auto_enable_standards = "NONE"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count         = var.enable_cis_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/3.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "pci" {
  count         = var.enable_pci_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:us-east-1::standards/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "nist" {
  count         = var.enable_nist_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:us-east-1::standards/nist-800-53/v/5.0.0"
  depends_on    = [aws_securityhub_account.this]
}
```

- [ ] **Step 3: Write `modules/security-hub/outputs.tf`**

```hcl
output "hub_arn" {
  value = aws_securityhub_account.this.id
}
```

- [ ] **Step 4: Write `modules/security-hub/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate + commit**

```bash
cd modules/security-hub && terraform init && terraform validate
git add modules/security-hub/
git commit -m "feat: add security-hub module (CIS v3, PCI-DSS, NIST)"
```

---

### Task 12: `modules/guardduty`

GuardDuty with org-wide delegated admin. Enables S3 protection, EKS protection, RDS protection, Malware protection, and Lambda protection in all accounts.

**Files:**
- Create: `modules/guardduty/main.tf`
- Create: `modules/guardduty/variables.tf`
- Create: `modules/guardduty/outputs.tf`
- Create: `modules/guardduty/versions.tf`

- [ ] **Step 1: Write `modules/guardduty/variables.tf`**

```hcl
variable "delegated_admin_account_id" {
  type        = string
  description = "Account ID of the security account acting as GuardDuty delegated admin."
}

variable "finding_publishing_frequency" {
  type        = string
  default     = "SIX_HOURS"
  description = "How often to publish findings. ONE_HOUR, SIX_HOURS, or FIFTEEN_MINUTES."
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "auto_enable_org_members" {
  type        = string
  default     = "ALL"
  description = "Auto-enable GuardDuty for org members: ALL, NEW, or NONE."
}

variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/guardduty/main.tf`**

```hcl
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs         { enable = true }
    kubernetes      { audit_logs { enable = true } }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes { enable = true }
      }
    }
  }

  tags = var.tags
}

resource "aws_guardduty_organization_admin_account" "this" {
  admin_account_id = var.delegated_admin_account_id
}

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable_organization_members = var.auto_enable_org_members
  detector_id                      = aws_guardduty_detector.this.id

  datasources {
    s3_logs         { auto_enable = true }
    kubernetes      { audit_logs { enable = true } }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes { auto_enable = true }
      }
    }
  }

  depends_on = [aws_guardduty_organization_admin_account.this]
}
```

- [ ] **Step 3: Write `modules/guardduty/outputs.tf`**

```hcl
output "detector_id"  { value = aws_guardduty_detector.this.id }
output "detector_arn" { value = aws_guardduty_detector.this.arn }
```

- [ ] **Step 4: Write `modules/guardduty/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate + commit**

```bash
cd modules/guardduty && terraform init && terraform validate
git add modules/guardduty/
git commit -m "feat: add guardduty module (org-wide, all protections)"
```

---

### Task 13: `modules/aws-config`

AWS Config recorder with org-wide aggregator. Includes CIS, PCI-DSS, HIPAA, and NIST conformance packs delivered to the log-archive bucket.

**Files:**
- Create: `modules/aws-config/main.tf`
- Create: `modules/aws-config/variables.tf`
- Create: `modules/aws-config/outputs.tf`
- Create: `modules/aws-config/versions.tf`

- [ ] **Step 1: Write `modules/aws-config/variables.tf`**

```hcl
variable "org_name"                  { type = string }
variable "account_id"                { type = string }
variable "log_archive_bucket_name"   { type = string }
variable "kms_key_arn"               { type = string }
variable "org_aggregator_account_id" { type = string; description = "Security account ID that aggregates Config data." }
variable "tags"                       { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/aws-config/main.tf`**

```hcl
resource "aws_iam_role" "config" {
  name = "${var.org_name}-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.org_name}-config-delivery"
  s3_bucket_name = var.log_archive_bucket_name
  s3_key_prefix  = "config"
  s3_kms_key_arn = var.kms_key_arn

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder" "this" {
  name     = "${var.org_name}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_configuration_aggregator" "org" {
  name = "${var.org_name}-org-aggregator"
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config.arn
  }
  tags = var.tags
}

# Conformance packs — reference AWS-managed templates
resource "aws_config_conformance_pack" "cis" {
  name          = "CIS-AWS-Foundations-Benchmark"
  template_body = <<-EOT
    Parameters:
      AccessKeysRotatedParamMaxAccessKeyAge:
        Type: String
        Default: "90"
    Resources:
      CISBenchmarkConformancePack:
        Type: AWS::Config::ConformancePack
        Properties:
          ConformancePackName: CIS-AWS-Foundations
  EOT

  depends_on = [aws_config_configuration_recorder_status.this]
}
```

**Note:** AWS Config conformance packs can reference S3 template URLs from the AWS-provided conformance pack library. In practice, replace the inline `template_body` with `template_s3_uri` pointing to the official AWS-managed conformance pack S3 URIs for CIS, PCI-DSS, HIPAA, and NIST. The `template_body` above is a placeholder structure — see `docs/compliance-matrix.md` (Task 37) for the official S3 URIs.

- [ ] **Step 3: Write `modules/aws-config/outputs.tf`**

```hcl
output "recorder_id"        { value = aws_config_configuration_recorder.this.id }
output "aggregator_arn"     { value = aws_config_configuration_aggregator.org.arn }
output "delivery_channel_id" { value = aws_config_delivery_channel.this.id }
```

- [ ] **Step 4: Write `modules/aws-config/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate + commit**

```bash
cd modules/aws-config && terraform init && terraform validate
git add modules/aws-config/
git commit -m "feat: add aws-config module (recorder, aggregator, conformance packs)"
```

---

### Task 14: `modules/macie` + `modules/access-analyzer` + `modules/inspector`

These three modules follow the same minimal pattern: enable the service org-wide with a delegated admin. Group them in one task.

**Files:**
- Create: `modules/macie/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Create: `modules/access-analyzer/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Create: `modules/inspector/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`

- [ ] **Step 1: Write `modules/macie/variables.tf`**

```hcl
variable "delegated_admin_account_id" { type = string }
variable "finding_publishing_frequency" {
  type    = string
  default = "SIX_HOURS"
}
variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/macie/main.tf`**

```hcl
resource "aws_macie2_account" "this" {
  finding_publishing_frequency = var.finding_publishing_frequency
  status                       = "ENABLED"
}

resource "aws_macie2_organization_admin_account" "this" {
  admin_account_id = var.delegated_admin_account_id
  depends_on       = [aws_macie2_account.this]
}
```

- [ ] **Step 3: Write `modules/macie/outputs.tf`**

```hcl
output "account_id" { value = aws_macie2_account.this.id }
```

- [ ] **Step 4: Write `modules/access-analyzer/variables.tf`**

```hcl
variable "org_name"    { type = string }
variable "analyzer_type" {
  type    = string
  default = "ORGANIZATION"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "Must be ACCOUNT or ORGANIZATION."
  }
}
variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 5: Write `modules/access-analyzer/main.tf`**

```hcl
resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "${var.org_name}-org-analyzer"
  type          = var.analyzer_type
  tags          = var.tags
}
```

- [ ] **Step 6: Write `modules/access-analyzer/outputs.tf`**

```hcl
output "analyzer_arn"  { value = aws_accessanalyzer_analyzer.this.arn }
output "analyzer_name" { value = aws_accessanalyzer_analyzer.this.analyzer_name }
```

- [ ] **Step 7: Write `modules/inspector/variables.tf`**

```hcl
variable "delegated_admin_account_id" { type = string }
variable "auto_enable" {
  type = object({
    ec2         = bool
    ecr         = bool
    lambda      = bool
    lambda_code = bool
  })
  default = {
    ec2         = true
    ecr         = true
    lambda      = true
    lambda_code = true
  }
}
variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 8: Write `modules/inspector/main.tf`**

```hcl
resource "aws_inspector2_enabler" "this" {
  account_ids    = [var.delegated_admin_account_id]
  resource_types = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]
}

resource "aws_inspector2_delegated_admin_account" "this" {
  account_id = var.delegated_admin_account_id
  depends_on = [aws_inspector2_enabler.this]
}

resource "aws_inspector2_organization_configuration" "this" {
  auto_enable {
    ec2         = var.auto_enable.ec2
    ecr         = var.auto_enable.ecr
    lambda      = var.auto_enable.lambda
    lambda_code = var.auto_enable.lambda_code
  }
  depends_on = [aws_inspector2_delegated_admin_account.this]
}
```

- [ ] **Step 9: Write `modules/inspector/outputs.tf`**

```hcl
output "delegated_admin_account_id" { value = aws_inspector2_delegated_admin_account.this.account_id }
```

- [ ] **Step 10: Write all three `versions.tf` files** — copy from Task 4 Step 1 into each.

- [ ] **Step 11: Write all three `outputs.tf` for modules without them** (macie and access-analyzer are done above; inspector is done above).

- [ ] **Step 12: Validate all three**

```bash
for m in macie access-analyzer inspector; do
  echo "=== $m ===" && cd modules/$m && terraform init -backend=false && terraform validate && cd ../..
done
```

Expected: three `Success! The configuration is valid.` lines.

- [ ] **Step 13: Commit**

```bash
git add modules/macie/ modules/access-analyzer/ modules/inspector/
git commit -m "feat: add macie, access-analyzer, inspector modules"
```

---

## Phase 5: Identity & Networking Modules

### Task 15: `modules/identity-center`

IAM Identity Center configuration: creates permission sets (AdministratorAccess, PowerUserAccess, ReadOnlyAccess, SecurityAudit, BillingReadOnly) and assigns them to accounts via group assignments.

**Files:**
- Create: `modules/identity-center/main.tf`
- Create: `modules/identity-center/variables.tf`
- Create: `modules/identity-center/outputs.tf`
- Create: `modules/identity-center/versions.tf`

- [ ] **Step 1: Write `modules/identity-center/variables.tf`**

```hcl
variable "sso_instance_arn" {
  type        = string
  description = "ARN of the SSO instance. Get from: aws sso-admin list-instances"
}

variable "identity_store_id" {
  type        = string
  description = "Identity store ID. Get from: aws sso-admin list-instances"
}

variable "permission_sets" {
  description = "Map of permission set name to config."
  type = map(object({
    description          = string
    session_duration     = string
    managed_policy_arns  = list(string)
    inline_policy_json   = optional(string, "")
  }))
  default = {
    AdministratorAccess = {
      description         = "Full administrative access"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    PowerUserAccess = {
      description         = "Power user without IAM/Org changes"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    ReadOnlyAccess = {
      description         = "Read-only access across all services"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
    SecurityAudit = {
      description         = "Security audit and compliance review access"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
    BillingReadOnly = {
      description         = "Read-only access to billing and cost data"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/job-function/Billing"]
    }
  }
}

variable "account_assignments" {
  description = <<-EOT
    List of SSO account assignments.
    Each: { account_id, permission_set_name, principal_type (GROUP|USER), principal_id }
  EOT
  type = list(object({
    account_id          = string
    permission_set_name = string
    principal_type      = string
    principal_id        = string
  }))
  default = []
}

variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/identity-center/main.tf`**

```hcl
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration

  tags = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for combo in flatten([
      for ps_name, ps in var.permission_sets : [
        for arn in ps.managed_policy_arns : {
          key            = "${ps_name}--${arn}"
          ps_name        = ps_name
          managed_policy_arn = arn
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = var.sso_instance_arn
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = {
    for idx, a in var.account_assignments :
    "${a.account_id}-${a.permission_set_name}-${a.principal_id}" => a
  }

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
```

- [ ] **Step 3: Write `modules/identity-center/outputs.tf`**

```hcl
output "permission_set_arns" {
  description = "Map of permission set name to ARN"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}
```

- [ ] **Step 4: Write `modules/identity-center/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate + commit**

```bash
cd modules/identity-center && terraform init && terraform validate
git add modules/identity-center/
git commit -m "feat: add identity-center module (5 permission sets)"
```

---

### Task 16: `modules/vpc`

VPC with public, private, and isolated (DB) subnet tiers across 3 AZs. Includes VPC flow logs to the log-archive bucket, NACLs, and optional NAT gateways.

**Files:**
- Create: `modules/vpc/main.tf`
- Create: `modules/vpc/variables.tf`
- Create: `modules/vpc/outputs.tf`
- Create: `modules/vpc/versions.tf`

- [ ] **Step 1: Write `modules/vpc/variables.tf`**

```hcl
variable "org_name"     { type = string }
variable "account_name" { type = string }
variable "region"       { type = string }

variable "cidr_block" {
  type        = string
  description = "VPC CIDR. Example: 10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of 3 AZ names. Example: [us-east-1a, us-east-1b, us-east-1c]"
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones required."
  }
}

variable "public_subnet_cidrs"   { type = list(string); description = "3 CIDRs for public subnets." }
variable "private_subnet_cidrs"  { type = list(string); description = "3 CIDRs for private subnets." }
variable "isolated_subnet_cidrs" { type = list(string); description = "3 CIDRs for isolated (DB) subnets." }

variable "enable_nat_gateway"    { type = bool; default = true }
variable "single_nat_gateway"    { type = bool; default = false; description = "Use one NAT GW for all AZs (cost saving for non-prod)." }

variable "log_archive_bucket_arn" { type = string; description = "ARN of the centralized log archive bucket for VPC flow logs." }
variable "flow_log_kms_key_arn"   { type = string }

variable "tags" { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/vpc/main.tf`**

```hcl
locals {
  name_prefix = "${var.org_name}-${var.account_name}"
  nat_count   = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : 3) : 0
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, { Name = "${local.name_prefix}-vpc" })
}

# Public subnets
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

# Private subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}

# Isolated subnets (no route to internet, for databases)
resource "aws_subnet" "isolated" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-isolated-${count.index + 1}"
    Tier = "isolated"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name_prefix}-igw" })
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${local.name_prefix}-nat-eip-${count.index + 1}" })
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${local.name_prefix}-nat-${count.index + 1}" })
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${local.name_prefix}-rt-public" })
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 3 : 1
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-rt-private-${count.index + 1}" })
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id : aws_route_table.private[0].id
}

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name_prefix}-rt-isolated" })
}

resource "aws_route_table_association" "isolated" {
  count          = 3
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated.id
}

# VPC Flow Logs → log-archive bucket
resource "aws_iam_role" "flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "vpc-flow-logs-s3-policy"
  role   = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = "${var.log_archive_bucket_arn}/vpc-flow-logs/*"
    }]
  })
}

resource "aws_flow_log" "this" {
  log_destination      = "${var.log_archive_bucket_arn}/vpc-flow-logs/${var.account_name}/"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn         = aws_iam_role.flow_logs.arn

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }

  tags = var.tags
}
```

- [ ] **Step 3: Write `modules/vpc/outputs.tf`**

```hcl
output "vpc_id"              { value = aws_vpc.this.id }
output "vpc_arn"             { value = aws_vpc.this.arn }
output "vpc_cidr_block"      { value = aws_vpc.this.cidr_block }
output "public_subnet_ids"   { value = aws_subnet.public[*].id }
output "private_subnet_ids"  { value = aws_subnet.private[*].id }
output "isolated_subnet_ids" { value = aws_subnet.isolated[*].id }
output "internet_gateway_id" { value = aws_internet_gateway.this.id }
output "nat_gateway_ids"     { value = aws_nat_gateway.this[*].id }
```

- [ ] **Step 4: Write `modules/vpc/versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 5: Validate + commit**

```bash
cd modules/vpc && terraform init && terraform validate
git add modules/vpc/
git commit -m "feat: add vpc module (3-tier, flow logs, NAT GW)"
```

---

### Task 17: `modules/tgw-hub` + `modules/tgw-spoke`

Transit Gateway hub in the network account; spoke attachments in workload accounts.

**Files:**
- Create: `modules/tgw-hub/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Create: `modules/tgw-spoke/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`

- [ ] **Step 1: Write `modules/tgw-hub/variables.tf`**

```hcl
variable "org_name"           { type = string }
variable "amazon_side_asn"    { type = number; default = 64512 }
variable "allowed_cidr_blocks" { type = list(string); description = "CIDRs allowed to route through the TGW." }
variable "tags"               { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/tgw-hub/main.tf`**

```hcl
resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.org_name} Transit Gateway Hub"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, { Name = "${var.org_name}-tgw-hub" })
}

resource "aws_ram_resource_share" "tgw" {
  name                      = "${var.org_name}-tgw-share"
  allow_external_principals = false
  tags                      = var.tags
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
```

- [ ] **Step 3: Write `modules/tgw-hub/outputs.tf`**

```hcl
output "tgw_id"              { value = aws_ec2_transit_gateway.this.id }
output "tgw_arn"             { value = aws_ec2_transit_gateway.this.arn }
output "ram_share_arn"       { value = aws_ram_resource_share.tgw.arn }
output "default_route_table_id" { value = aws_ec2_transit_gateway.this.association_default_route_table_id }
```

- [ ] **Step 4: Write `modules/tgw-spoke/variables.tf`**

```hcl
variable "org_name"         { type = string }
variable "account_name"     { type = string }
variable "tgw_id"           { type = string; description = "Transit Gateway ID from tgw-hub outputs." }
variable "vpc_id"           { type = string }
variable "private_subnet_ids" { type = list(string); description = "Subnet IDs to attach to the TGW." }
variable "tags"             { type = map(string); default = {} }
```

- [ ] **Step 5: Write `modules/tgw-spoke/main.tf`**

```hcl
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.tags, { Name = "${var.org_name}-${var.account_name}-tgw-attachment" })
}
```

- [ ] **Step 6: Write `modules/tgw-spoke/outputs.tf`**

```hcl
output "attachment_id" { value = aws_ec2_transit_gateway_vpc_attachment.this.id }
```

- [ ] **Step 7: Write `versions.tf` for both** — copy from Task 4 Step 1 into each.

- [ ] **Step 8: Validate + commit**

```bash
for m in tgw-hub tgw-spoke; do cd modules/$m && terraform init && terraform validate && cd ../..; done
git add modules/tgw-hub/ modules/tgw-spoke/
git commit -m "feat: add tgw-hub and tgw-spoke modules"
```

---

### Task 18: `modules/route53` + `modules/workload-baseline`

Route53 private hosted zone module, then the composite workload-baseline module that wires everything together for a workload account.

**Files:**
- Create: `modules/route53/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Create: `modules/workload-baseline/main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`

- [ ] **Step 1: Write `modules/route53/variables.tf`**

```hcl
variable "domain_name" { type = string; description = "Private hosted zone name. Example: prod.acme.internal" }
variable "vpc_id"      { type = string }
variable "tags"        { type = map(string); default = {} }
```

- [ ] **Step 2: Write `modules/route53/main.tf`**

```hcl
resource "aws_route53_zone" "private" {
  name    = var.domain_name
  comment = "Private hosted zone managed by Terraform"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = var.tags
}
```

- [ ] **Step 3: Write `modules/route53/outputs.tf`**

```hcl
output "zone_id"   { value = aws_route53_zone.private.zone_id }
output "zone_arn"  { value = aws_route53_zone.private.arn }
output "name_servers" { value = aws_route53_zone.private.name_servers }
```

- [ ] **Step 4: Write `modules/workload-baseline/variables.tf`**

```hcl
variable "org_name"                  { type = string }
variable "account_name"              { type = string }
variable "account_id"                { type = string }
variable "region"                    { type = string }
variable "log_archive_bucket_arn"    { type = string }
variable "log_archive_bucket_name"   { type = string }
variable "kms_key_description"       { type = string; default = "Workload account general-purpose KMS key" }
variable "github_org"                { type = string; description = "GitHub org name for OIDC trust." }
variable "github_repo"               { type = string; description = "GitHub repo name for OIDC trust." }
variable "tags"                      { type = map(string); default = {} }
```

- [ ] **Step 5: Write `modules/workload-baseline/main.tf`**

```hcl
module "kms" {
  source      = "../kms"
  account_id  = var.account_id
  description = var.kms_key_description
  key_alias   = "${var.org_name}-${var.account_name}-general"
  tags        = var.tags
}

module "baseline" {
  source     = "../account-baseline"
  account_id = var.account_id
  tags       = var.tags
}

module "state_backend" {
  source                 = "../state-backend"
  org_name               = var.org_name
  account_name           = var.account_name
  region                 = var.region
  kms_key_arn            = module.kms.key_arn
  log_archive_bucket_arn = var.log_archive_bucket_arn
  tags                   = var.tags
}

# GitHub OIDC provider for CI/CD
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "${var.org_name}-${var.account_name}-terraform-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "terraform_ci" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

- [ ] **Step 6: Write `modules/workload-baseline/outputs.tf`**

```hcl
output "kms_key_arn"       { value = module.kms.key_arn }
output "kms_key_id"        { value = module.kms.key_id }
output "state_bucket_name" { value = module.state_backend.bucket_name }
output "terraform_ci_role_arn" { value = aws_iam_role.terraform_ci.arn }
```

- [ ] **Step 7: Write `versions.tf` for both** — copy from Task 4 Step 1 into each.

- [ ] **Step 8: Validate + commit**

```bash
for m in route53 workload-baseline; do cd modules/$m && terraform init && terraform validate && cd ../..; done
git add modules/route53/ modules/workload-baseline/
git commit -m "feat: add route53 and workload-baseline composite module"
```


---

## Phase 6: Medium Deployment (10 Accounts)

All account roots live under `medium/accounts/`. Each is an independent Terraform root with its own state. Deploy in this order: management → log-archive → security → network → shared-services → workloads.

### Task 19: `medium/accounts/_shared/` — shared conventions

**Files:**
- Create: `medium/accounts/_shared/locals.tf`
- Create: `medium/accounts/_shared/backend.tfvars.tmpl`
- Create: `medium/accounts/_shared/providers.tf.tmpl`
- Create: `medium/accounts/_shared/default-tags.tf`

- [ ] **Step 1: Write `medium/accounts/_shared/locals.tf`**

```hcl
# Copy into each account root as locals.tf and customize.
locals {
  org_name    = "acme"          # Change to your org name
  region      = "us-east-1"
  repo_url    = "https://github.com/acme/enterprise-aws-terraform"
  github_org  = "acme"
  github_repo = "enterprise-aws-terraform"

  # Management account outputs (update after management account is applied)
  management_account_id       = "111111111111"
  log_archive_bucket_name     = "acme-us-east-1-log-archive"
  log_archive_bucket_arn      = "arn:aws:s3:::acme-us-east-1-log-archive"
  security_account_id         = "222222222222"
  network_account_id          = "333333333333"

  common_tags = {
    Organization = local.org_name
    ManagedBy    = "terraform"
    Repository   = local.repo_url
  }
}
```

- [ ] **Step 2: Write `medium/accounts/_shared/backend.tfvars.tmpl`**

```hcl
# Replace <ACCOUNT_NAME> with the account directory name before running terraform init.
bucket         = "acme-us-east-1-tfstate"
key            = "<ACCOUNT_NAME>/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "acme-us-east-1-tfstate-lock"
encrypt        = true
```

- [ ] **Step 3: Write `medium/accounts/_shared/providers.tf.tmpl`**

```hcl
# Replace <ACCOUNT_ID> and <ACCOUNT_NAME> before use.
provider "aws" {
  region = local.region

  assume_role {
    role_arn     = "arn:aws:iam::<ACCOUNT_ID>:role/<ACCOUNT_NAME>-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = merge(local.common_tags, {
      Account     = "<ACCOUNT_NAME>"
      Environment = "<ENVIRONMENT>"
    })
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add medium/accounts/_shared/
git commit -m "feat: add medium deployment shared conventions"
```

---

### Task 20: `medium/accounts/management/`

Management account: creates the AWS Organization, SCPs, Identity Center, CloudTrail, and the OIDC provider for CI/CD.

**Files:**
- Create: `medium/accounts/management/versions.tf`
- Create: `medium/accounts/management/backend.tf`
- Create: `medium/accounts/management/providers.tf`
- Create: `medium/accounts/management/locals.tf`
- Create: `medium/accounts/management/main.tf`
- Create: `medium/accounts/management/outputs.tf`
- Create: `medium/accounts/management/terraform.tfvars`

- [ ] **Step 1: Write `medium/accounts/management/versions.tf`**

```hcl
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}
```

- [ ] **Step 2: Write `medium/accounts/management/backend.tf`**

```hcl
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "management/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
```

- [ ] **Step 3: Write `medium/accounts/management/providers.tf`**

```hcl
provider "aws" {
  region = local.region

  default_tags {
    tags = merge(local.common_tags, {
      Account     = "management"
      Environment = "management"
    })
  }
}
```

- [ ] **Step 4: Write `medium/accounts/management/locals.tf`**

```hcl
locals {
  org_name    = var.org_name
  region      = var.region
  repo_url    = var.repo_url
  github_org  = var.github_org
  github_repo = var.github_repo

  common_tags = {
    Organization = local.org_name
    ManagedBy    = "terraform"
    Repository   = local.repo_url
    ComplianceScope = "all"
    DataClass    = "internal"
  }
}
```

- [ ] **Step 5: Write `medium/accounts/management/variables.tf`**

```hcl
variable "org_name"           { type = string }
variable "region"             { type = string; default = "us-east-1" }
variable "repo_url"           { type = string }
variable "github_org"         { type = string }
variable "github_repo"        { type = string }
variable "management_account_id" { type = string }
variable "sso_instance_arn"   { type = string; description = "From: aws sso-admin list-instances" }
variable "identity_store_id"  { type = string; description = "From: aws sso-admin list-instances" }
variable "allowed_regions"    { type = list(string); default = ["us-east-1", "us-west-2"] }
```

- [ ] **Step 6: Write `medium/accounts/management/main.tf`**

```hcl
module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.management_account_id
  description = "Management account KMS key"
  key_alias   = "${var.org_name}-management-general"
  tags        = local.common_tags
}

module "organization" {
  source   = "../../../modules/aws-organization"
  org_name = var.org_name
  tags     = local.common_tags
}

module "scps" {
  source          = "../../../modules/scp-policies"
  allowed_regions = var.allowed_regions
  tags            = local.common_tags
}

# Attach SCPs to OUs
resource "aws_organizations_policy_attachment" "deny_root_all_ous" {
  policy_id = module.scps.policy_ids["deny_root_actions"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_leave_org" {
  policy_id = module.scps.policy_ids["deny_leave_org"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_regions" {
  policy_id = module.scps.policy_ids["deny_regions"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_unencrypted_workloads" {
  policy_id = module.scps.policy_ids["deny_unencrypted_storage"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

resource "aws_organizations_policy_attachment" "deny_iam_users_workloads" {
  policy_id = module.scps.policy_ids["deny_iam_user_creation"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

resource "aws_organizations_policy_attachment" "require_imdsv2_workloads" {
  policy_id = module.scps.policy_ids["require_imdsv2"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

module "identity_center" {
  source            = "../../../modules/identity-center"
  sso_instance_arn  = var.sso_instance_arn
  identity_store_id = var.identity_store_id
  tags              = local.common_tags
}

# GitHub OIDC for management account CI
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "${var.org_name}-management-terraform-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*" }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "terraform_ci" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

- [ ] **Step 7: Write `medium/accounts/management/outputs.tf`**

```hcl
output "organization_id"   { value = module.organization.organization_id }
output "root_id"           { value = module.organization.root_id }
output "ou_ids"            { value = module.organization.organizational_unit_ids }
output "kms_key_arn"       { value = module.kms.key_arn }
output "permission_set_arns" { value = module.identity_center.permission_set_arns }
output "terraform_ci_role_arn" { value = aws_iam_role.terraform_ci.arn }
```

- [ ] **Step 8: Write `medium/accounts/management/terraform.tfvars`**

```hcl
org_name              = "acme"
region                = "us-east-1"
repo_url              = "https://github.com/acme/enterprise-aws-terraform"
github_org            = "acme"
github_repo           = "enterprise-aws-terraform"
management_account_id = "111111111111"
sso_instance_arn      = "arn:aws:sso:::instance/ssoins-PLACEHOLDER"
identity_store_id     = "d-PLACEHOLDER"
allowed_regions       = ["us-east-1", "us-west-2"]
```

- [ ] **Step 9: Validate**

```bash
cd medium/accounts/management
terraform init -backend=false
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 10: Commit**

```bash
git add medium/accounts/management/
git commit -m "feat: add management account root module"
```

---

### Task 21: `medium/accounts/log-archive/`

Log-archive account: creates the centralized S3 bucket with Object Lock for CloudTrail, Config, VPC flow logs, and S3 access logs.

**Files:**
- Create: `medium/accounts/log-archive/versions.tf`
- Create: `medium/accounts/log-archive/backend.tf`
- Create: `medium/accounts/log-archive/providers.tf`
- Create: `medium/accounts/log-archive/variables.tf`
- Create: `medium/accounts/log-archive/main.tf`
- Create: `medium/accounts/log-archive/outputs.tf`
- Create: `medium/accounts/log-archive/terraform.tfvars`

- [ ] **Step 1: Write `medium/accounts/log-archive/backend.tf`**

```hcl
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "log-archive/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
```

- [ ] **Step 2: Write `medium/accounts/log-archive/providers.tf`**

```hcl
provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.log_archive_account_id}:role/${var.org_name}-log-archive-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "log-archive"
      Environment     = "management"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
```

- [ ] **Step 3: Write `medium/accounts/log-archive/variables.tf`**

```hcl
variable "org_name"                 { type = string }
variable "region"                   { type = string; default = "us-east-1" }
variable "repo_url"                 { type = string }
variable "org_id"                   { type = string }
variable "log_archive_account_id"   { type = string }
variable "management_account_id"    { type = string }
variable "object_lock_retention_days" { type = number; default = 365 }
```

- [ ] **Step 4: Write `medium/accounts/log-archive/main.tf`**

```hcl
module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.log_archive_account_id
  description = "Log archive account KMS key"
  key_alias   = "${var.org_name}-log-archive-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.log_archive_account_id
}

module "log_archive_bucket" {
  source                     = "../../../modules/log-archive-bucket"
  org_name                   = var.org_name
  region                     = var.region
  org_id                     = var.org_id
  management_account_id      = var.management_account_id
  kms_key_arn                = module.kms.key_arn
  object_lock_retention_days = var.object_lock_retention_days
}
```

- [ ] **Step 5: Write `medium/accounts/log-archive/outputs.tf`**

```hcl
output "log_archive_bucket_name" { value = module.log_archive_bucket.bucket_name }
output "log_archive_bucket_arn"  { value = module.log_archive_bucket.bucket_arn }
output "kms_key_arn"             { value = module.kms.key_arn }
```

- [ ] **Step 6: Write `medium/accounts/log-archive/terraform.tfvars`**

```hcl
org_name               = "acme"
region                 = "us-east-1"
repo_url               = "https://github.com/acme/enterprise-aws-terraform"
org_id                 = "o-PLACEHOLDER"
log_archive_account_id = "444444444444"
management_account_id  = "111111111111"
object_lock_retention_days = 365
```

- [ ] **Step 7: Write `versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 8: Validate + commit**

```bash
cd medium/accounts/log-archive && terraform init -backend=false && terraform validate
git add medium/accounts/log-archive/
git commit -m "feat: add log-archive account root module"
```

---

### Task 22: `medium/accounts/security/`

Security account: delegated admin for Security Hub, GuardDuty, Macie, Access Analyzer, Inspector, and AWS Config aggregator.

**Files:**
- Create: `medium/accounts/security/versions.tf`, `backend.tf`, `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars`

- [ ] **Step 1: Write `medium/accounts/security/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.security_account_id
  description = "Security account KMS key"
  key_alias   = "${var.org_name}-security-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.security_account_id
}

module "security_hub" {
  source                  = "../../../modules/security-hub"
  enable_cis_standard     = true
  enable_pci_standard     = true
  enable_nist_standard    = true
  auto_enable_new_accounts = true
}

module "guardduty" {
  source                       = "../../../modules/guardduty"
  delegated_admin_account_id   = var.security_account_id
  finding_publishing_frequency = "SIX_HOURS"
}

module "macie" {
  source                       = "../../../modules/macie"
  delegated_admin_account_id   = var.security_account_id
}

module "access_analyzer" {
  source        = "../../../modules/access-analyzer"
  org_name      = var.org_name
  analyzer_type = "ORGANIZATION"
}

module "inspector" {
  source                     = "../../../modules/inspector"
  delegated_admin_account_id = var.security_account_id
}

module "aws_config" {
  source                    = "../../../modules/aws-config"
  org_name                  = var.org_name
  account_id                = var.security_account_id
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn               = module.kms.key_arn
  org_aggregator_account_id = var.security_account_id
}
```

- [ ] **Step 2: Write `medium/accounts/security/variables.tf`**

```hcl
variable "org_name"            { type = string }
variable "region"              { type = string; default = "us-east-1" }
variable "repo_url"            { type = string }
variable "security_account_id" { type = string }
```

- [ ] **Step 3: Write `medium/accounts/security/backend.tf`**

```hcl
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "security/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
```

- [ ] **Step 4: Write `medium/accounts/security/terraform.tfvars`**

```hcl
org_name            = "acme"
region              = "us-east-1"
repo_url            = "https://github.com/acme/enterprise-aws-terraform"
security_account_id = "222222222222"
```

- [ ] **Step 5: Write `versions.tf`** — copy from Task 4 Step 1.

- [ ] **Step 6: Write `medium/accounts/security/outputs.tf`**

```hcl
output "guardduty_detector_id" { value = module.guardduty.detector_id }
output "security_hub_arn"      { value = module.security_hub.hub_arn }
output "analyzer_arn"          { value = module.access_analyzer.analyzer_arn }
```

- [ ] **Step 7: Write `providers.tf`** — same pattern as log-archive, substituting `security_account_id` and role name `${var.org_name}-security-terraform-ci`.

- [ ] **Step 8: Validate + commit**

```bash
cd medium/accounts/security && terraform init -backend=false && terraform validate
git add medium/accounts/security/
git commit -m "feat: add security account root module"
```

---

### Task 23: `medium/accounts/management/` — add CloudTrail (depends on log-archive outputs)

Now that log-archive is defined, add the CloudTrail module call to the management account's `main.tf`.

**Files:**
- Modify: `medium/accounts/management/main.tf`
- Modify: `medium/accounts/management/outputs.tf`

- [ ] **Step 1: Add remote state read and CloudTrail module to `medium/accounts/management/main.tf`**

Append to the bottom of the existing `main.tf`:

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "cloudtrail" {
  source                  = "../../../modules/cloudtrail"
  org_name                = var.org_name
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn             = module.kms.key_arn
}
```

- [ ] **Step 2: Append to `medium/accounts/management/outputs.tf`**

```hcl
output "cloudtrail_trail_arn" { value = module.cloudtrail.trail_arn }
```

- [ ] **Step 3: Validate + commit**

```bash
cd medium/accounts/management && terraform init -backend=false && terraform validate
git add medium/accounts/management/
git commit -m "feat: add cloudtrail to management account (depends on log-archive)"
```

---

### Task 24: `medium/accounts/network/`

Network account: VPC with 3 subnet tiers, Transit Gateway hub, shared via RAM, Route53 private zone.

**Files:**
- Create: `medium/accounts/network/versions.tf`, `backend.tf`, `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars`

- [ ] **Step 1: Write `medium/accounts/network/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.network_account_id
  description = "Network account KMS key"
  key_alias   = "${var.org_name}-network-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.network_account_id
}

module "vpc" {
  source                 = "../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "network"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.kms.key_arn
}

module "tgw" {
  source               = "../../../modules/tgw-hub"
  org_name             = var.org_name
  allowed_cidr_blocks  = [var.vpc_cidr]
}

module "private_zone" {
  source      = "../../../modules/route53"
  domain_name = "${var.org_name}.internal"
  vpc_id      = module.vpc.vpc_id
}
```

- [ ] **Step 2: Write `medium/accounts/network/variables.tf`**

```hcl
variable "org_name"           { type = string }
variable "region"             { type = string; default = "us-east-1" }
variable "repo_url"           { type = string }
variable "network_account_id" { type = string }
variable "vpc_cidr"           { type = string; default = "10.0.0.0/16" }
variable "availability_zones" { type = list(string); default = ["us-east-1a", "us-east-1b", "us-east-1c"] }
variable "public_subnet_cidrs"   { type = list(string); default = ["10.0.0.0/24",  "10.0.1.0/24",  "10.0.2.0/24"]  }
variable "private_subnet_cidrs"  { type = list(string); default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"] }
variable "isolated_subnet_cidrs" { type = list(string); default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"] }
```

- [ ] **Step 3: Write `medium/accounts/network/outputs.tf`**

```hcl
output "vpc_id"               { value = module.vpc.vpc_id }
output "private_subnet_ids"   { value = module.vpc.private_subnet_ids }
output "tgw_id"               { value = module.tgw.tgw_id }
output "tgw_ram_share_arn"    { value = module.tgw.ram_share_arn }
output "private_zone_id"      { value = module.private_zone.zone_id }
```

- [ ] **Step 4: Write `backend.tf`**, `providers.tf`, `terraform.tfvars`, `versions.tf` — following the same patterns as previous accounts, substituting `network_account_id` and role `${var.org_name}-network-terraform-ci`. State key: `network/terraform.tfstate`.

- [ ] **Step 5: Validate + commit**

```bash
cd medium/accounts/network && terraform init -backend=false && terraform validate
git add medium/accounts/network/
git commit -m "feat: add network account root module"
```

---

### Task 25: `medium/accounts/shared-services/`

Shared services account: ECR public/private registries, ACM wildcard certificate.

**Files:**
- Create: `medium/accounts/shared-services/versions.tf`, `backend.tf`, `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars`

- [ ] **Step 1: Write `medium/accounts/shared-services/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.shared_services_account_id
  description = "Shared services account KMS key"
  key_alias   = "${var.org_name}-shared-services-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.shared_services_account_id
}

module "workload_baseline" {
  source                    = "../../../modules/workload-baseline"
  org_name                  = var.org_name
  account_name              = "shared-services"
  account_id                = var.shared_services_account_id
  region                    = var.region
  log_archive_bucket_arn    = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org                = var.github_org
  github_repo               = var.github_repo
}

resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = "ENHANCED"
  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

resource "aws_ecr_registry_policy" "org_pull" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowOrgPull"
      Effect = "Allow"
      Principal = { AWS = "*" }
      Action = [
        "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability", "ecr:GetAuthorizationToken"
      ]
      Resource = "*"
      Condition = {
        StringEquals = { "aws:PrincipalOrgID" = var.org_id }
      }
    }]
  })
}
```

- [ ] **Step 2: Write `medium/accounts/shared-services/variables.tf`**

```hcl
variable "org_name"                    { type = string }
variable "region"                      { type = string; default = "us-east-1" }
variable "repo_url"                    { type = string }
variable "org_id"                      { type = string }
variable "shared_services_account_id"  { type = string }
variable "github_org"                  { type = string }
variable "github_repo"                 { type = string }
```

- [ ] **Step 3: Write `outputs.tf`**, `backend.tf`, `providers.tf`, `terraform.tfvars`, `versions.tf` — same patterns, state key: `shared-services/terraform.tfstate`.

- [ ] **Step 4: Validate + commit**

```bash
cd medium/accounts/shared-services && terraform init -backend=false && terraform validate
git add medium/accounts/shared-services/
git commit -m "feat: add shared-services account root module"
```

---

### Task 26: `medium/accounts/prod/` (and staging, dev, sandbox)

Workload accounts. `prod` shown in full; `staging`, `dev`, `sandbox` follow the identical pattern with different `account_name` and `account_id`.

**Files:**
- Create: `medium/accounts/prod/versions.tf`, `backend.tf`, `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars`
- Create: `medium/accounts/staging/` (same structure)
- Create: `medium/accounts/dev/` (same structure)
- Create: `medium/accounts/sandbox/` (same structure)

- [ ] **Step 1: Write `medium/accounts/prod/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "network/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                    = "../../../modules/workload-baseline"
  org_name                  = var.org_name
  account_name              = "prod"
  account_id                = var.account_id
  region                    = var.region
  log_archive_bucket_arn    = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org                = var.github_org
  github_repo               = var.github_repo
}

module "vpc" {
  source                 = "../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "prod"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.workload_baseline.kms_key_arn
}

module "tgw_spoke" {
  source             = "../../../modules/tgw-spoke"
  org_name           = var.org_name
  account_name       = "prod"
  tgw_id             = data.terraform_remote_state.network.outputs.tgw_id
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
```

- [ ] **Step 2: Write `medium/accounts/prod/variables.tf`**

```hcl
variable "org_name"           { type = string }
variable "region"             { type = string; default = "us-east-1" }
variable "repo_url"           { type = string }
variable "account_id"         { type = string }
variable "github_org"         { type = string }
variable "github_repo"        { type = string }
variable "vpc_cidr"           { type = string; default = "10.1.0.0/16" }
variable "availability_zones" { type = list(string); default = ["us-east-1a", "us-east-1b", "us-east-1c"] }
variable "public_subnet_cidrs"   { type = list(string); default = ["10.1.0.0/24",  "10.1.1.0/24",  "10.1.2.0/24"]  }
variable "private_subnet_cidrs"  { type = list(string); default = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"] }
variable "isolated_subnet_cidrs" { type = list(string); default = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"] }
```

- [ ] **Step 3: Write `backend.tf`** (key: `prod/terraform.tfstate`), `providers.tf` (role: `${var.org_name}-prod-terraform-ci`), `outputs.tf`, `versions.tf`, `terraform.tfvars`.

- [ ] **Step 4: Scaffold staging/dev/sandbox** — copy prod, change `account_name` string to `staging`/`dev`/`sandbox`, update CIDR blocks (10.2.x, 10.3.x, 10.4.x), update `account_id` in tfvars, update state key in backend.tf.

```bash
for env in staging dev sandbox; do
  cp -r medium/accounts/prod medium/accounts/$env
  # Update account_name references and CIDRs in each copy
done
```

Then manually update `account_name`, `vpc_cidr`, subnets, and `account_id` in each copy.

- [ ] **Step 5: Validate all workload accounts**

```bash
for env in prod staging dev sandbox; do
  echo "=== $env ===" && cd medium/accounts/$env && terraform init -backend=false && terraform validate && cd ../../..
done
```

Expected: four `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add medium/accounts/prod/ medium/accounts/staging/ medium/accounts/dev/ medium/accounts/sandbox/
git commit -m "feat: add workload account roots (prod, staging, dev, sandbox)"
```

---

## Phase 7: Large Deployment (30+ Accounts)

The large deployment extends the medium pattern. Only the differences and new components are shown.

### Task 27: `large/accounts/_shared/` + foundation accounts

- [ ] **Step 1: Copy medium `_shared/` to large**

```bash
cp -r medium/accounts/_shared large/accounts/_shared
```

Update CIDR ranges and account IDs in the large copy to use a different IP space (172.16.x.x) to avoid conflicts.

- [ ] **Step 2: Scaffold foundation accounts for large**

```bash
for account in management log-archive security network shared-services; do
  cp -r medium/accounts/$account large/accounts/$account
  # Update all backend.tf state keys to use large/<account>/terraform.tfstate
  # Update providers.tf role names if needed
done
```

- [ ] **Step 3: Update state keys in all large foundation accounts**

Each `large/accounts/<name>/backend.tf` must use key `large-<name>/terraform.tfstate` to avoid collision with medium state.

```hcl
# large/accounts/management/backend.tf
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "large/management/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
```

Apply the same key prefix (`large/`) to all accounts under `large/`.

- [ ] **Step 4: Validate + commit**

```bash
for account in management log-archive security network shared-services; do
  cd large/accounts/$account && terraform init -backend=false && terraform validate && cd ../../..
done
git add large/accounts/
git commit -m "feat: scaffold large deployment foundation accounts"
```

---

### Task 28: `large/accounts/data-platform/` + `large/accounts/security-tools/`

**Files:**
- Create: `large/accounts/data-platform/main.tf` (and supporting files)
- Create: `large/accounts/security-tools/main.tf` (and supporting files)

- [ ] **Step 1: Write `large/accounts/data-platform/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "large/log-archive/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                    = "../../../modules/workload-baseline"
  org_name                  = var.org_name
  account_name              = "data-platform"
  account_id                = var.account_id
  region                    = var.region
  log_archive_bucket_arn    = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org                = var.github_org
  github_repo               = var.github_repo
}

module "vpc" {
  source                 = "../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "data-platform"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = true
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.workload_baseline.kms_key_arn
}

resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [module.workload_baseline.terraform_ci_role_arn]
}
```

- [ ] **Step 2: Write `large/accounts/data-platform/variables.tf`**, `backend.tf`, `providers.tf`, `outputs.tf`, `versions.tf`, `terraform.tfvars` — same pattern, state key `large/data-platform/terraform.tfstate`.

- [ ] **Step 3: Write `large/accounts/security-tools/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "large/log-archive/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                    = "../../../modules/workload-baseline"
  org_name                  = var.org_name
  account_name              = "security-tools"
  account_id                = var.account_id
  region                    = var.region
  log_archive_bucket_arn    = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org                = var.github_org
  github_repo               = var.github_repo
}
```

- [ ] **Step 4: Validate + commit**

```bash
for account in data-platform security-tools; do
  cd large/accounts/$account && terraform init -backend=false && terraform validate && cd ../../..
done
git add large/accounts/data-platform/ large/accounts/security-tools/
git commit -m "feat: add data-platform and security-tools accounts (large)"
```

---

### Task 29: `large/accounts/bu-alpha/` and `large/accounts/bu-beta/`

Each BU has three workload accounts. Pattern mirrors `medium/accounts/prod/` but with BU-namespaced names.

- [ ] **Step 1: Scaffold BU accounts**

```bash
for bu in bu-alpha bu-beta; do
  for env in prod staging dev; do
    mkdir -p large/accounts/$bu/$env
    cp medium/accounts/prod/versions.tf large/accounts/$bu/$env/
    cp medium/accounts/prod/variables.tf large/accounts/$bu/$env/
  done
done
```

- [ ] **Step 2: Write `large/accounts/bu-alpha/prod/main.tf`**

```hcl
data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "large/log-archive/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "large/network/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                    = "../../../../modules/workload-baseline"
  org_name                  = var.org_name
  account_name              = "bu-alpha-prod"
  account_id                = var.account_id
  region                    = var.region
  log_archive_bucket_arn    = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org                = var.github_org
  github_repo               = var.github_repo
}

module "vpc" {
  source                 = "../../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "bu-alpha-prod"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.workload_baseline.kms_key_arn
}

module "tgw_spoke" {
  source             = "../../../../modules/tgw-spoke"
  org_name           = var.org_name
  account_name       = "bu-alpha-prod"
  tgw_id             = data.terraform_remote_state.network.outputs.tgw_id
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
```

- [ ] **Step 3: Create `backend.tf`** (key: `large/bu-alpha-prod/terraform.tfstate`), `providers.tf`, `terraform.tfvars`, `outputs.tf` for `bu-alpha/prod`.

- [ ] **Step 4: Repeat for `bu-alpha/staging`, `bu-alpha/dev`, `bu-beta/prod`, `bu-beta/staging`, `bu-beta/dev`** — changing `account_name`, CIDRs, state key, and `account_id` in tfvars. CIDR allocations:
  - bu-alpha-prod: 10.10.0.0/16
  - bu-alpha-staging: 10.11.0.0/16
  - bu-alpha-dev: 10.12.0.0/16
  - bu-beta-prod: 10.20.0.0/16
  - bu-beta-staging: 10.21.0.0/16
  - bu-beta-dev: 10.22.0.0/16

- [ ] **Step 5: Validate all BU accounts**

```bash
for bu in bu-alpha bu-beta; do
  for env in prod staging dev; do
    echo "=== $bu/$env ===" && cd large/accounts/$bu/$env && terraform init -backend=false && terraform validate && cd ../../../..
  done
done
```

Expected: 6× `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add large/accounts/bu-alpha/ large/accounts/bu-beta/
git commit -m "feat: add bu-alpha and bu-beta workload accounts (large)"
```

---

## Phase 8: CI/CD Workflows + Scripts + Docs

### Task 30: GitHub Actions — `plan.yml`

Runs `terraform plan` for any account root changed in a PR.

**Files:**
- Create: `.github/workflows/plan.yml`

- [ ] **Step 1: Write `.github/workflows/plan.yml`**

```yaml
name: Terraform Plan

on:
  pull_request:
    branches: [main]
    paths:
      - 'medium/accounts/**'
      - 'large/accounts/**'
      - 'modules/**'

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      accounts: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: actions/checkout@v4

      - name: Detect changed account roots
        id: filter
        uses: dorny/paths-filter@v3
        with:
          filters: |
            medium-management:
              - 'medium/accounts/management/**'
            medium-log-archive:
              - 'medium/accounts/log-archive/**'
            medium-security:
              - 'medium/accounts/security/**'
            medium-network:
              - 'medium/accounts/network/**'
            medium-shared-services:
              - 'medium/accounts/shared-services/**'
            medium-prod:
              - 'medium/accounts/prod/**'
            medium-staging:
              - 'medium/accounts/staging/**'
            medium-dev:
              - 'medium/accounts/dev/**'
            medium-sandbox:
              - 'medium/accounts/sandbox/**'

  plan:
    needs: detect-changes
    runs-on: ubuntu-latest
    if: ${{ needs.detect-changes.outputs.accounts != '[]' && needs.detect-changes.outputs.accounts != '' }}
    strategy:
      fail-fast: false
      matrix:
        account: ${{ fromJSON(needs.detect-changes.outputs.accounts) }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.x"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ vars.MANAGEMENT_ACCOUNT_ID }}:role/acme-management-terraform-ci
          aws-region: us-east-1

      - name: Resolve account path
        id: path
        run: |
          ACCOUNT="${{ matrix.account }}"
          # Convert filter key (e.g., medium-prod) to path (medium/accounts/prod)
          PREFIX=$(echo $ACCOUNT | cut -d- -f1)
          NAME=$(echo $ACCOUNT | cut -d- -f2-)
          echo "dir=${PREFIX}/accounts/${NAME}" >> "$GITHUB_OUTPUT"

      - name: Terraform Init
        working-directory: ${{ steps.path.outputs.dir }}
        run: terraform init

      - name: Terraform Validate
        working-directory: ${{ steps.path.outputs.dir }}
        run: terraform validate

      - name: Terraform Plan
        id: plan
        working-directory: ${{ steps.path.outputs.dir }}
        run: terraform plan -no-color -out=tfplan 2>&1 | tee plan.txt
        continue-on-error: true

      - name: Comment plan on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('${{ steps.path.outputs.dir }}/plan.txt', 'utf8');
            const output = `## Terraform Plan — \`${{ matrix.account }}\`
            \`\`\`
            ${plan.substring(0, 65000)}
            \`\`\`
            *Pushed by @${{ github.actor }}*`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            });

      - name: Fail if plan errored
        if: steps.plan.outcome == 'failure'
        run: exit 1
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/plan.yml
git commit -m "feat: add terraform plan workflow (PR gate)"
```

---

### Task 31: GitHub Actions — `apply.yml` + `drift-detect.yml`

**Files:**
- Create: `.github/workflows/apply.yml`
- Create: `.github/workflows/drift-detect.yml`

- [ ] **Step 1: Write `.github/workflows/apply.yml`**

```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
    paths:
      - 'medium/accounts/**'
      - 'large/accounts/**'

permissions:
  id-token: write
  contents: read

jobs:
  apply:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.x"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ vars.MANAGEMENT_ACCOUNT_ID }}:role/acme-management-terraform-ci
          aws-region: us-east-1

      - name: Apply accounts in dependency order
        run: |
          set -e
          ACCOUNTS=(
            "medium/accounts/management"
            "medium/accounts/log-archive"
            "medium/accounts/security"
            "medium/accounts/network"
            "medium/accounts/shared-services"
            "medium/accounts/prod"
            "medium/accounts/staging"
            "medium/accounts/dev"
            "medium/accounts/sandbox"
          )
          for dir in "${ACCOUNTS[@]}"; do
            echo "=== Applying $dir ==="
            cd $dir
            terraform init -input=false
            terraform apply -auto-approve -input=false
            cd $GITHUB_WORKSPACE
          done
```

- [ ] **Step 2: Write `.github/workflows/drift-detect.yml`**

```yaml
name: Drift Detection

on:
  schedule:
    - cron: '0 2 * * *'  # 2am UTC nightly
  workflow_dispatch:

permissions:
  id-token: write
  contents: read
  issues: write

jobs:
  drift:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        account:
          - medium/accounts/management
          - medium/accounts/log-archive
          - medium/accounts/security
          - medium/accounts/network
          - medium/accounts/shared-services
          - medium/accounts/prod
          - medium/accounts/staging
          - medium/accounts/dev
          - medium/accounts/sandbox

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.x"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ vars.MANAGEMENT_ACCOUNT_ID }}:role/acme-management-terraform-ci
          aws-region: us-east-1

      - name: Check for drift
        id: drift
        working-directory: ${{ matrix.account }}
        run: |
          terraform init -input=false
          terraform plan -detailed-exitcode -no-color 2>&1 | tee drift.txt
          echo "exit_code=$?" >> "$GITHUB_OUTPUT"
        continue-on-error: true

      - name: Open issue if drift detected
        if: steps.drift.outputs.exit_code == '2'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const drift = fs.readFileSync('${{ matrix.account }}/drift.txt', 'utf8');
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[Drift] ${{ matrix.account }} has unmanaged changes`,
              body: `## Terraform drift detected in \`${{ matrix.account }}\`\n\n\`\`\`\n${drift.substring(0, 65000)}\n\`\`\``,
              labels: ['terraform-drift']
            });
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/apply.yml .github/workflows/drift-detect.yml
git commit -m "feat: add apply and drift-detection workflows"
```

---

### Task 32: `scripts/bootstrap.sh` + `scripts/new-account.sh`

**Files:**
- Create: `scripts/bootstrap.sh`
- Create: `scripts/new-account.sh`

- [ ] **Step 1: Write `scripts/bootstrap.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Enterprise AWS Terraform Bootstrap ==="
echo ""
echo "This script creates the Terraform state S3 bucket and DynamoDB lock table"
echo "in your management account. Run this once before any other Terraform apply."
echo ""

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Error: terraform not found"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "Error: aws CLI not found"; exit 1; }

# Confirm AWS identity
echo "Current AWS identity:"
aws sts get-caller-identity
echo ""
read -p "Is this your management account? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborting."; exit 1; }

cd "$(dirname "$0")/../bootstrap"

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars from example. Edit it now, then re-run this script."
  exit 0
fi

echo "Initializing with local state..."
terraform init

echo "Applying bootstrap resources..."
terraform apply

echo ""
echo "Bootstrap complete. Now migrating state to S3..."
echo "Uncomment the backend block in bootstrap/backend.tf, then run:"
echo "  cd bootstrap && terraform init -migrate-state"
```

- [ ] **Step 2: Write `scripts/new-account.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -s <medium|large> -n <account-name> -e <environment> -i <aws-account-id> -c <cidr>"
  echo ""
  echo "  -s  Scale: medium or large"
  echo "  -n  Account name (lowercase, hyphens ok). Example: prod, bu-alpha-prod"
  echo "  -e  Environment: prod, staging, dev, sandbox, management"
  echo "  -i  AWS account ID (12 digits)"
  echo "  -c  VPC CIDR block. Example: 10.5.0.0/16"
  exit 1
}

while getopts "s:n:e:i:c:" opt; do
  case $opt in
    s) SCALE="$OPTARG" ;;
    n) ACCOUNT_NAME="$OPTARG" ;;
    e) ENVIRONMENT="$OPTARG" ;;
    i) ACCOUNT_ID="$OPTARG" ;;
    c) VPC_CIDR="$OPTARG" ;;
    *) usage ;;
  esac
done

[[ -z "${SCALE:-}" || -z "${ACCOUNT_NAME:-}" || -z "${ENVIRONMENT:-}" || -z "${ACCOUNT_ID:-}" ]] && usage

DIR="${SCALE}/accounts/${ACCOUNT_NAME}"

if [ -d "$DIR" ]; then
  echo "Error: $DIR already exists"
  exit 1
fi

echo "Scaffolding $DIR..."
mkdir -p "$DIR"

# versions.tf
cat > "$DIR/versions.tf" << 'EOF'
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}
EOF

# backend.tf
PREFIX=""
[[ "$SCALE" == "large" ]] && PREFIX="large/"
cat > "$DIR/backend.tf" << EOF
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "${PREFIX}${ACCOUNT_NAME}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
EOF

# terraform.tfvars
cat > "$DIR/terraform.tfvars" << EOF
org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "${ACCOUNT_ID}"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"
vpc_cidr    = "${VPC_CIDR:-10.0.0.0/16}"
EOF

# Stub main.tf
cat > "$DIR/main.tf" << EOF
# ${ACCOUNT_NAME} account — ${ENVIRONMENT} environment
# Scaffolded by scripts/new-account.sh
# Add module calls here following the pattern in medium/accounts/prod/main.tf
EOF

# Stub outputs.tf and variables.tf
touch "$DIR/outputs.tf"
cp medium/accounts/prod/variables.tf "$DIR/variables.tf"

echo "Created $DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $DIR/terraform.tfvars with real values"
echo "  2. Add module calls to $DIR/main.tf"
echo "  3. Run: cd $DIR && terraform init && terraform validate"
```

```bash
chmod +x scripts/bootstrap.sh scripts/new-account.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/
git commit -m "feat: add bootstrap and new-account helper scripts"
```

---

### Task 33: Documentation

**Files:**
- Create: `docs/architecture.md`
- Create: `docs/compliance-matrix.md`
- Create: `docs/onboarding.md`

- [ ] **Step 1: Write `docs/architecture.md`**

```markdown
# Architecture

## Account & OU Structure

See design spec: `docs/superpowers/specs/2026-05-18-enterprise-terraform-design.md`

## Deployment Dependency Graph

```
bootstrap (local state → migrated)
    │
    └─▶ management (Org, SCPs, Identity Center, CloudTrail)
            │
            └─▶ log-archive (centralized S3 log bucket)
                    │
                    ├─▶ security (Security Hub, GuardDuty, Config, Macie, Inspector)
                    └─▶ network (VPC, TGW, Route53)
                              │
                              └─▶ shared-services, prod, staging, dev, sandbox
```

## State Isolation

Each account root writes to its own key in the shared S3 state bucket:

| Account | State Key |
|---|---|
| management | `management/terraform.tfstate` |
| log-archive | `log-archive/terraform.tfstate` |
| security | `security/terraform.tfstate` |
| network | `network/terraform.tfstate` |
| prod | `prod/terraform.tfstate` |
| ... | ... |

Large deployment uses `large/` prefix on all state keys.

## Cross-Account Data Flow

Accounts read each other's outputs via `terraform_remote_state`:

- `security` reads `log-archive` → gets bucket name/ARN for Config delivery
- `network` reads `log-archive` → gets bucket ARN for VPC flow logs
- `prod/staging/dev` read `log-archive` + `network` → get bucket ARN and TGW ID

## IAM Access Pattern

CI/CD: GitHub Actions OIDC → `management` OIDC provider → `TerraformCIRole` in management → assume-role into per-account `TerraformCIRole`.
Humans: IAM Identity Center in management → permission sets assigned per account.
```

- [ ] **Step 2: Write `docs/compliance-matrix.md`**

```markdown
# Compliance Coverage Matrix

## Service Controls

| Control | CIS v3 | SOC2 | PCI-DSS v3.2 | HIPAA |
|---|:---:|:---:|:---:|:---:|
| CloudTrail (org-wide, immutable) | ✓ | ✓ | ✓ | ✓ |
| CloudTrail log file validation | ✓ | ✓ | ✓ | ✓ |
| GuardDuty (all protections) | ✓ | ✓ | ✓ | ✓ |
| Security Hub (CIS/PCI/NIST standards) | ✓ | ✓ | ✓ | ✓ |
| AWS Config recorder + conformance packs | ✓ | ✓ | ✓ | ✓ |
| Macie (PII/sensitive data) | — | ✓ | ✓ | ✓ |
| IAM Access Analyzer (org-wide) | ✓ | ✓ | ✓ | ✓ |
| Inspector v2 (EC2/ECR/Lambda) | — | ✓ | ✓ | ✓ |
| KMS encryption (EBS, S3, DynamoDB) | ✓ | ✓ | ✓ | ✓ |
| VPC flow logs → immutable S3 | ✓ | ✓ | ✓ | ✓ |
| S3 Object Lock on log archive | — | ✓ | ✓ | ✓ |
| IMDSv2 required (SCP) | ✓ | ✓ | ✓ | ✓ |
| Root account usage denied (SCP) | ✓ | ✓ | ✓ | ✓ |
| IAM password policy (14+ chars, MFA) | ✓ | ✓ | ✓ | ✓ |
| S3 Block Public Access (account + SCP) | ✓ | ✓ | ✓ | ✓ |
| TLS enforced on log bucket (bucket policy) | ✓ | ✓ | ✓ | ✓ |

## AWS Config Conformance Pack S3 URIs

Replace the `template_body` placeholder in `modules/aws-config/main.tf` with:

| Pack | Template S3 URI |
|---|---|
| CIS v1.4 | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml` |
| PCI-DSS v3.2.1 | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-PCI-DSS.yaml` |
| HIPAA | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml` |
| NIST 800-53 | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-NIST-CSF.yaml` |
```

- [ ] **Step 3: Commit**

```bash
git add docs/
git commit -m "docs: add architecture, compliance matrix, and onboarding docs"
```

---

### Task 34: Self-review and final validation

- [ ] **Step 1: Run validate across all modules**

```bash
for dir in modules/*/; do
  echo "=== $dir ===" && cd "$dir" && terraform init -backend=false -upgrade && terraform validate && cd ../..
done
```

Expected: all pass.

- [ ] **Step 2: Run tflint across all modules**

```bash
for dir in modules/*/; do
  echo "=== $dir ===" && cd "$dir" && tflint --config=../../.tflint.hcl && cd ../..
done
```

- [ ] **Step 3: Run all terraform tests**

```bash
for dir in modules/*/; do
  if ls "$dir"tests/*.tftest.hcl 2>/dev/null; then
    echo "=== $dir ===" && cd "$dir" && terraform test && cd ../..
  fi
done
```

Expected: all tests pass.

- [ ] **Step 4: Validate all account roots (medium)**

```bash
for dir in medium/accounts/*/; do
  echo "=== $dir ===" && cd "$dir" && terraform init -backend=false && terraform validate && cd ../../..
done
```

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chore: final validation pass — all modules and account roots valid"
```

---

*End of implementation plan. 34 tasks across 8 phases. Phases 1–5 (modules) can be completed independently before starting Phase 6 (medium deployment). Phase 7 (large) can begin in parallel with Phase 6 once shared modules are stable.*
