# Enterprise AWS Terraform Organization

Production-ready Terraform template for a complete enterprise AWS organization.
Covers CIS AWS Foundations, SOC 2, PCI-DSS, and HIPAA compliance by default.

## Architecture

```mermaid
flowchart TB
    classDef mgmt fill:#fef3c7,stroke:#b45309,color:#000
    classDef sec fill:#fee2e2,stroke:#b91c1c,color:#000
    classDef infra fill:#dbeafe,stroke:#1d4ed8,color:#000
    classDef wl fill:#dcfce7,stroke:#15803d,color:#000
    classDef ext fill:#f5f5f5,stroke:#525252,color:#000

    GH[GitHub Actions<br/>OIDC]:::ext
    HUMANS[Humans<br/>via IdP - Okta/AAD/Google]:::ext

    subgraph ROOT["AWS Organization Root"]
      direction TB

      subgraph SEC["Security OU"]
        MGMT["management<br/>━━━━━━━━━<br/>Org + SCPs + Tag Policies<br/>Identity Center personas<br/>CloudTrail org-trail<br/>OIDC provider + CI roles<br/>SNS by severity<br/>CUR + Cost Anomaly Detection<br/>Service Catalog"]:::mgmt
        SECURITY["security<br/>━━━━━━━━━<br/>Security Hub delegated admin<br/>GuardDuty + auto-remediation<br/>AWS Config + conformance packs<br/>Macie / Inspector / Access Analyzer<br/>Audit Manager<br/>Athena + Glue over log archive<br/>Central AWS Backup vault"]:::sec
        LOG["log-archive<br/>━━━━━━━━━<br/>Centralized S3 bucket<br/>S3 Object Lock - WORM<br/>Cross-region replication<br/>CloudTrail / VPC flow logs / Config<br/>SES bounce + complaint sink"]:::sec
      end

      subgraph INF["Infrastructure OU"]
        NET["network<br/>━━━━━━━━━<br/>VPC + flow logs<br/>Transit Gateway hub<br/>Route53 private zones<br/>DNS Firewall<br/>Network Firewall<br/>Client VPN"]:::infra
        SHARED["shared-services<br/>━━━━━━━━━<br/>ECR with org-wide pull policy<br/>SES + Cognito baselines<br/>Internal tooling"]:::infra
      end

      subgraph WL["Workloads OU"]
        PROD["prod"]:::wl
        STAGE["staging"]:::wl
        DEV["dev"]:::wl
        SBX["sandbox"]:::wl
      end
    end

    GH -->|sts:AssumeRoleWithWebIdentity| MGMT
    MGMT -->|sts:AssumeRole| SECURITY
    MGMT -->|sts:AssumeRole| LOG
    MGMT -->|sts:AssumeRole| NET
    MGMT -->|sts:AssumeRole| SHARED
    MGMT -->|sts:AssumeRole| PROD
    MGMT -->|sts:AssumeRole| STAGE
    MGMT -->|sts:AssumeRole| DEV
    MGMT -->|sts:AssumeRole| SBX

    HUMANS -->|SSO permission sets| MGMT

    PROD -.->|CloudTrail / VPC flow logs| LOG
    STAGE -.->|CloudTrail / VPC flow logs| LOG
    DEV -.->|CloudTrail / VPC flow logs| LOG
    SBX -.->|CloudTrail / VPC flow logs| LOG
    NET -.->|VPC flow logs| LOG
    SHARED -.->|CloudTrail| LOG

    PROD -.->|GuardDuty / Config / Security Hub| SECURITY
    STAGE -.->|GuardDuty / Config / Security Hub| SECURITY
    DEV -.->|GuardDuty / Config / Security Hub| SECURITY
    SBX -.->|GuardDuty / Config / Security Hub| SECURITY

    NET ===|Transit Gateway via RAM| PROD
    NET ===|Transit Gateway via RAM| STAGE
    NET ===|Transit Gateway via RAM| DEV

    SECURITY -->|alerts| MGMT
```

**Legend** — yellow: management trust root · red: security/audit accounts · blue: shared infrastructure · green: workloads · solid arrows: IAM trust · dotted: telemetry/logging · double lines: network connectivity

## What's included

- **`modules/`** — 45 reusable Terraform modules (no state) — see catalog below
- **`medium/`** — 10-account reference deployment
- **`large/`** — 30+ account reference deployment (with BU structure, account-vending, multi-region modules)
- **`bootstrap/`** — One-time state infrastructure setup
- **`policies/`** — Rego policies enforced via Conftest in CI
- **`.github/workflows/`** — Plan on PR, apply on merge, nightly drift detection, Conftest policy check

## Module Catalog

### Foundation — org, accounts, state

| Module | Purpose |
|---|---|
| [`aws-organization`](modules/aws-organization) | AWS Organization + OUs, enable trusted service access |
| [`scp-policies`](modules/scp-policies) | 8 SCPs (deny root, deny leave-org, region allowlist, IMDSv2, S3 public block, deny IAM users, deny unencrypted storage, deny VPC changes) |
| [`tag-policies`](modules/tag-policies) | Organizations tag policy enforcing Environment / DataClass / ComplianceScope / CostCenter |
| [`account-baseline`](modules/account-baseline) | Per-account hardening: S3 block-public, EBS default encryption, IMDSv2 default, CIS password policy, budget alert |
| [`account-vending`](modules/account-vending) | Map-driven account creation via Organizations API with OU placement |
| [`workload-baseline`](modules/workload-baseline) | Composite for workload accounts: KMS + account-baseline + state-backend + secrets-baseline + GitHub OIDC CI role |
| [`state-backend`](modules/state-backend) | Per-account S3 + DynamoDB for Terraform state |
| [`kms`](modules/kms) | KMS key with rotation, configurable admins/users, alias |

### Identity & access

| Module | Purpose |
|---|---|
| [`identity-center`](modules/identity-center) | IAM Identity Center: 5 managed permission sets + custom persona sets + SSO groups + account assignments with GROUP resolution |

### Security services

| Module | Purpose |
|---|---|
| [`cloudtrail`](modules/cloudtrail) | Org-wide multi-region trail with log file validation, S3+Lambda data events, ApiCallRateInsights |
| [`aws-config`](modules/aws-config) | Config recorder + org aggregator + CIS / PCI-DSS / HIPAA / NIST conformance packs |
| [`security-hub`](modules/security-hub) | Security Hub with CIS v3, PCI-DSS, NIST 800-53 standards |
| [`guardduty`](modules/guardduty) | Org-wide GuardDuty with all detection features (S3, EKS, EBS malware, RDS, Lambda) |
| [`guardduty-auto-remediation`](modules/guardduty-auto-remediation) | EventBridge severity routing + Lambda auto-quarantine for high-confidence findings |
| [`macie`](modules/macie) | Org-wide Macie for PII / sensitive data discovery |
| [`inspector`](modules/inspector) | Org-wide Inspector v2 (EC2 / ECR / Lambda / Lambda code) |
| [`access-analyzer`](modules/access-analyzer) | Org-wide IAM Access Analyzer |
| [`audit-manager`](modules/audit-manager) | Org-wide Audit Manager delegated admin |

### Logging & observability

| Module | Purpose |
|---|---|
| [`log-archive-bucket`](modules/log-archive-bucket) | Centralized log S3 bucket with Object Lock (WORM), versioning, KMS-SSE, optional cross-region replication |
| [`log-querying`](modules/log-querying) | Athena workgroup + Glue tables over CloudTrail and VPC flow logs |
| [`notifications`](modules/notifications) | SNS topics per severity (critical/high/medium/low/info) + EventBridge bus + 365-day archive + Chatbot scaffolding |

### Networking

| Module | Purpose |
|---|---|
| [`vpc`](modules/vpc) | 3-tier VPC (public/private/isolated) with flow logs to S3, gateway endpoints (S3, DynamoDB), 10 interface endpoints |
| [`route53`](modules/route53) | Private hosted zone associated with a VPC |
| [`tgw-hub`](modules/tgw-hub) | Transit Gateway hub with RAM resource share |
| [`tgw-spoke`](modules/tgw-spoke) | VPC attachment to a shared TGW |
| [`tgw-peering`](modules/tgw-peering) | Cross-region TGW peering for multi-region active-active |
| [`network-firewall`](modules/network-firewall) | AWS Network Firewall with stateful domain allowlist + AWS-managed threat-intel rule groups |
| [`dns-firewall`](modules/dns-firewall) | Route53 Resolver DNS Firewall with custom + AWS-managed domain lists |
| [`client-vpn`](modules/client-vpn) | Workforce VPN with SAML federation or mutual cert auth, split tunneling |
| [`session-manager`](modules/session-manager) | SSH-free EC2 access with S3 + CloudWatch session logging |
| [`waf-baseline`](modules/waf-baseline) | WAFv2 ACL with 5 AWS managed rule groups + rate limiting + optional Shield Advanced |

### Compute

| Module | Purpose |
|---|---|
| [`ecs-cluster`](modules/ecs-cluster) | Fargate cluster with Container Insights + ECS Exec with KMS-encrypted logs |
| [`eks-cluster`](modules/eks-cluster) | EKS with private endpoint, envelope-encrypted secrets, all control-plane logs, managed node group |
| [`lambda-baseline`](modules/lambda-baseline) | ARM64 Lambda with X-Ray, KMS log encryption, optional VPC + DLQ |

### Databases

| Module | Purpose |
|---|---|
| [`rds-baseline`](modules/rds-baseline) | RDS Postgres/MySQL with enforced TLS, audit logs, Secrets Manager-managed password, Performance Insights |
| [`aurora-baseline`](modules/aurora-baseline) | Aurora cluster (Postgres/MySQL) with the same compliance guarantees |
| [`aurora-global`](modules/aurora-global) | Aurora Global Database spanning primary + secondary regions |
| [`dynamodb-baseline`](modules/dynamodb-baseline) | DynamoDB with SSE-KMS, PITR, deletion protection, optional streams + TTL |

### Application services

| Module | Purpose |
|---|---|
| [`cognito-baseline`](modules/cognito-baseline) | User pool with mandatory MFA, advanced security ENFORCED, 14-char password policy |
| [`ses-baseline`](modules/ses-baseline) | SESv2 with auto-DKIM, custom MAIL FROM + SPF, DMARC, bounce/complaint SNS routing |

### Resilience & governance

| Module | Purpose |
|---|---|
| [`aws-backup`](modules/aws-backup) | Central backup vault with Vault Lock, daily/weekly/monthly plans, tag-based selection, cross-region copy |
| [`chaos-engineering`](modules/chaos-engineering) | AWS FIS experiment templates (EC2 stop, AZ blackhole, RDS failover) with CloudWatch stop conditions |
| [`cost-management`](modules/cost-management) | Cost & Usage Report + Cost Anomaly Detection + org-wide monthly budget |
| [`secrets-baseline`](modules/secrets-baseline) | Per-account Secrets Manager KMS key + rotation Lambda IAM + unrotated-secret Config rule |
| [`service-catalog`](modules/service-catalog) | Service Catalog portfolio + CloudFormation products + principal associations for developer self-service |

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

See `docs/architecture.md` for the full dependency graph.

## Compliance

See `docs/compliance-matrix.md` for which controls each module implements
across CIS, SOC 2, PCI-DSS, and HIPAA.
