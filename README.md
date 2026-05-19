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

- **`modules/`** — 30+ reusable Terraform modules (no state)
- **`medium/`** — 10-account reference deployment
- **`large/`** — 30+ account reference deployment (with BU structure, account-vending, multi-region modules)
- **`bootstrap/`** — One-time state infrastructure setup
- **`policies/`** — Rego policies enforced via Conftest in CI
- **`.github/workflows/`** — Plan on PR, apply on merge, nightly drift detection, Conftest policy check

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
