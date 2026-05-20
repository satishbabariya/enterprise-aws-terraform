# Changelog

All notable changes to this template are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project does not yet have versioned releases — `main` is the consumable
ref. Pin to a specific commit SHA for reproducibility.

## [Unreleased]

### Added (Tier D)
- Repository hygiene: status badges, issue templates (bug report, feature
  request, compliance gap), CHANGELOG.md, AFT integration skeleton

## 2026-05-19 — Tier C: Operations docs

### Added
- `docs/cost-analysis.md` — itemized monthly cost per account class with
  cost-balloon flags and reduction levers; medium-scale baseline ~$2.6K/mo
- `docs/migration-from-existing-org.md` — 8–12 week phased plan to bring an
  existing AWS Org under this template; per-phase commands and SCP rollout
  guidance
- `docs/disaster-recovery-runbook.md` — 6 named scenarios (Aurora failure,
  region outage, log archive recovery, compromised credentials, etc.) with
  detection signals, exact commands, verification steps

### Changed
- README now has an Operations docs table linking all 8 docs

## 2026-05-19 — Tier B: Developer experience

### Added
- `examples/sample-workload-ecs/` — end-to-end deployment composing
  `workload-baseline` + `vpc` + `ecs-cluster` + `aurora-baseline` +
  `waf-baseline` into a containerized HTTPS app
- README sections for local developer setup, pre-commit hooks, running CI
  gates locally
- Provider pinning explanation with 5.x → 6.x compatibility notes

### Changed
- All 47 modules + bootstrap + 22 account roots pin AWS provider to `~> 5.0`
  (permits 5.x minor/patch, blocks 6.x major)
- `apply.yml` converted to manual `workflow_dispatch` only; requires typed
  `APPLY` confirmation + `scale=medium|large` selector

## 2026-05-19 — Tier A: Engineering rigor

### Added
- 69 unit tests using `terraform test` + `mock_provider` across 10 modules
  (cloudtrail, log-archive-bucket, security-hub, guardduty, vpc,
  eks-cluster, kms, rds-baseline, dynamodb-baseline, lambda-baseline)
- `.github/workflows/lint.yml` — fmt + per-module validate matrix + tflint +
  tfsec + checkov as PR gates
- `.github/workflows/test.yml` — `terraform test` matrix
- `.github/workflows/docs.yml` — auto-generates per-module READMEs via
  terraform-docs; fails PRs that don't regenerate, auto-commits on push
- `.checkov.yml` with 25 documented skip checks for module-level false
  positives
- `scripts/generate-module-docs.sh` + `scripts/stub-module-readmes.sh`

### Fixed
- `modules/eks-cluster` `coalesce(null, null)` bug in addon
  service_account_role_arn (would crash for coredns/kube-proxy)
- Athena results bucket now has versioning + S3 access logging
- GuardDuty quarantine Lambda now has X-Ray tracing enabled
- State + log + Athena buckets now have abort-incomplete-multipart lifecycle
- Network Firewall + policy + rule groups now accept customer KMS

## 2026-05-19 — Module audit batches

### Added (CloudPosse parity)
- `modules/security-hub`: finding aggregator (multi-region), automation
  rules (auto-suppress accepted controls), product subscriptions
- `modules/guardduty`: Runtime Monitoring (ECS Fargate / EC2 / EKS),
  org-wide feature configuration
- `modules/aws-config`: managed rules variable, optional SNS notifications
- `modules/vpc`: EKS subnet tags (kubernetes.io/role/elb + internal-elb)
- `modules/eks-cluster`: managed addons (vpc-cni, coredns, kube-proxy,
  ebs-csi-driver), IAM OIDC provider, auto-IRSA roles
- `modules/kms`: key_usage + customer_master_key_spec (asymmetric support)
- `modules/rds-baseline`: gp3 IOPS + throughput, blue/green updates,
  apply_immediately
- `modules/aurora-baseline`: optional RDS Proxy
- `modules/dynamodb-baseline`: GSI + LSI + Global Tables v2 replicas
- `modules/lambda-baseline`: layers, permissions_boundary, Function URLs,
  Lambda Insights
- `modules/ecs-cluster`: container_insights_mode (enhanced default)

## 2026-05-19 — CloudTrail audit pipeline

### Added
- `modules/cloudtrail` enhanced: internal KMS-encrypted CloudWatch log
  group, 15 CIS metric filters + paired alarms (CIS 3.1–3.14 + Org changes),
  ApiCallRateInsight + ApiErrorRateInsight, trail-stopped alarm, EventBridge
  auto-remediation rules (public SG ingress, IAM user creation, S3 public
  access change, IAM access key creation), CW log group class variable
- `modules/cloudtrail-lake` — Event Data Store with 7-year retention,
  termination protection, advanced event selectors
- `modules/kms-multi-region` — primary + replica with matching alias
- `modules/log-archive-bucket` hardened: `aws:SourceArn` + `aws:SourceAccount`
  conditions on CloudTrail write, `s3:x-amz-acl = bucket-owner-full-control`
  required, `DenyExternalPrincipals` blanket deny, `BucketOwnerEnforced`
  ownership, cross-account `AuditReader` role
- `modules/log-querying` — 7 saved Athena queries for CIS canonical
  investigations (root usage, no-MFA logins, KMS deletion, VPC top talkers)

## 2026-05-18 — Access management

### Added
- 8 SSO persona groups (PlatformAdmins, AppDevelopers Prod/NonProd,
  SecurityEngineers, Auditors, FinanceTeam, ExternalContractors, BreakGlass)
- 5 custom least-privilege permission sets with inline policies
- Break-glass alerting via CloudWatch metric filter on CloudTrail
- External contractor role enforces MFA + optional source-IP allowlist
- `docs/access-management.md` with persona matrix and onboarding flow

## 2026-05-18 — Tier 3: Specialized modules

### Added
- `modules/network-firewall` — stateful firewall with domain allowlist +
  AWS-managed threat-intel rule groups
- `modules/dns-firewall` — Route53 Resolver DNS Firewall
- `modules/client-vpn` — workforce VPN with SAML federation
- `modules/tgw-peering` — cross-region Transit Gateway peering
- `modules/aurora-global` — Aurora Global Database
- `modules/cognito-baseline` — user pool with mandatory MFA, advanced
  security ENFORCED
- `modules/ses-baseline` — SESv2 with auto-DKIM/SPF/DMARC, bounce/complaint
  SNS routing
- `modules/chaos-engineering` — AWS FIS experiment templates
- `policies/` — 4 Rego policies for Conftest (deny public S3, require
  encryption, require tags, no IAM users)
- `.github/workflows/policy-check.yml` — Conftest gate on PRs
- `docs/multi-region-strategy.md`

## 2026-05-18 — Tier 2: Compute, data, lifecycle

### Added
- `modules/session-manager` — SSH-free EC2 access with S3 + CloudWatch
  session logging
- `modules/log-querying` — Athena workgroup + Glue catalog over CloudTrail
  and VPC flow logs (partition projection enabled)
- `modules/rds-baseline`, `modules/aurora-baseline`,
  `modules/dynamodb-baseline` — compliance-hardened database baselines
- `modules/ecs-cluster`, `modules/eks-cluster`, `modules/lambda-baseline` —
  compute baselines
- `modules/guardduty-auto-remediation` — EventBridge severity routing +
  Lambda auto-quarantine for high-confidence findings
- `modules/account-vending` — map-driven account creation via Organizations
  API
- `modules/audit-manager` — org-wide delegated admin
- `modules/service-catalog` — portfolio + products for developer self-service
- Drift detection extended to all 13 `large/*` accounts

## 2026-05-18 — Tier 1: Enterprise quick wins

### Added
- `modules/aws-backup` — central backup vault with Vault Lock, daily/weekly/
  monthly plans, tag-based selection, cross-region copy
- `modules/tag-policies` — Organizations TAG_POLICY enforcing Environment /
  DataClass / ComplianceScope / CostCenter
- `modules/secrets-baseline` — per-account Secrets Manager KMS key, rotation
  Lambda IAM, unrotated-secret Config rule
- `modules/notifications` — SNS topics per severity + EventBridge bus +
  365-day archive + Chatbot scaffolding
- `modules/waf-baseline` — WAFv2 ACL with 5 AWS managed rule groups + rate
  limiting + optional Shield Advanced
- `modules/cost-management` — Cost & Usage Report + Cost Anomaly Detection +
  org-wide monthly budget
- `modules/aws-config`: CIS/PCI-DSS/HIPAA/NIST conformance packs
- `modules/vpc`: Gateway endpoints (S3, DynamoDB) + 10 Interface endpoints
- `modules/log-archive-bucket`: cross-region replication
- `modules/workload-baseline`: now composes `secrets-baseline`
- Repo hygiene: LICENSE (Apache 2.0), SECURITY.md, CODEOWNERS, PR template,
  CONTRIBUTING.md

## 2026-05-18 — Initial template

### Added
- Bootstrap module — S3 + DynamoDB + KMS for Terraform state
- Foundation modules — aws-organization, scp-policies, account-baseline,
  state-backend, kms, identity-center, workload-baseline
- Security modules — cloudtrail, security-hub, guardduty, aws-config, macie,
  inspector, access-analyzer
- Networking modules — vpc, route53, tgw-hub, tgw-spoke
- Logging — log-archive-bucket with S3 Object Lock (WORM)
- Medium deployment — 10-account reference (management, security,
  log-archive, network, shared-services, prod, staging, dev, sandbox)
- Large deployment — 13+ account reference with BU structure
- GitHub Actions — plan.yml (PR gate), apply.yml, drift-detect.yml
- `bootstrap.sh` and `new-account.sh` scaffolding scripts
- Initial docs — architecture, compliance-matrix, onboarding
