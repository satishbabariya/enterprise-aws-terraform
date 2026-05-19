# Cost Analysis

Itemized estimate of what this template costs to *run* (not including the
applications you deploy on top of it). All figures in USD, us-east-1 pricing
as of 2026-Q2. Your bill will vary with org-wide activity volume — places
where it can balloon are flagged.

> **TL;DR for medium scale (10 accounts, 1 region, light workload activity):
> $2,000–4,000/month before any application compute.**

## Cost categories per account

### Always-on baseline (every account)

| Service | Cost driver | Typical / month |
|---|---|---|
| KMS keys | $1 per CMK | $4–8 (each account has 2–4: general, secrets, sometimes per-service) |
| CloudWatch Logs storage | $0.03/GB | $5–50 depending on log volume |
| CloudWatch Logs ingestion | $0.50/GB | $20–200 depending on activity |
| AWS Config recorder | $0.003 per configuration item recorded + $0.001 per evaluation | $30–150 (scales with #resources × #rules) |
| Security Hub findings | $0.0010 per finding | $10–80 (CIS + PCI + NIST × number of resources) |
| GuardDuty | Per GB of CloudTrail + VPC flow + DNS logs analyzed | $30–150 (mostly VPC flow log volume) |
| Inspector v2 (EC2) | $1.25 per scanned instance/month + $0.09 per ECR image scan | $0–100 (zero if no EC2/ECR) |
| Macie | $1.00/GB of S3 data scanned (sensitive data discovery jobs) | $0–500 (off by default; only when you run jobs) |
| Access Analyzer | Free for org-internal findings | $0 |
| **Subtotal baseline** | | **$100–1,200/account** |

### Management account additions

| Service | Cost driver | Typical / month |
|---|---|---|
| CloudTrail org trail | Management events free; data events $0.10/100k | $20–500 (S3 + Lambda data events get expensive at scale) |
| CloudTrail Insights | $0.35 per 100k events analyzed | $5–30 |
| CloudTrail Lake | $2.50/GB ingested + $2.50/GB/month stored | $50–500 (depends on org event volume) |
| Cost & Usage Report | Free; storage in log-archive S3 | $0 |
| Cost Anomaly Detection | Free | $0 |
| SNS topic publishing | Per-million publishes | < $5 |
| **Subtotal management** | | **$75–1,000 additional** |

### Log-archive account additions

| Service | Cost driver | Typical / month |
|---|---|---|
| S3 standard storage | $0.023/GB first 50 TB | $25–500 (grows over time; lifecycle to Glacier helps) |
| S3 Glacier storage | $0.004/GB | $5–100 (after 365-day transition) |
| S3 PUT requests | $0.005 per 1k | $5–50 (write volume from CloudTrail + VPC flow logs) |
| Cross-region replication | Data transfer + destination storage | $20–200 if enabled |
| S3 Object Lock retention | Free (storage already counted) | $0 |
| **Subtotal log-archive** | | **$55–850 additional** |

### Security account additions

| Service | Cost driver | Typical / month |
|---|---|---|
| Audit Manager | $1.25 per assessment/month + $0.0019 per resource assessed | $50–300 |
| Athena query scans | $5.00 per TB scanned | $0–200 (depends on investigation volume) |
| Glue catalog | $1 per 100k objects/month | < $5 |
| **Subtotal security** | | **$55–500 additional** |

### Network account additions

| Service | Cost driver | Typical / month |
|---|---|---|
| Transit Gateway hub | $0.05/hour per attachment | $36 per attached VPC |
| TGW data processing | $0.02/GB | Variable |
| Route53 private hosted zone | $0.50/zone/month | $0.50 |
| Client VPN | $0.10/hour endpoint + $0.05/hour/connection | $72/month endpoint baseline + per-user usage |
| Network Firewall | $0.395/hour per endpoint | **$285/month per AZ × 3 AZs = $855** (large at-scale cost) |
| DNS Firewall | $0.60/million DNS queries | $5–50 |
| **Subtotal network** | | **$108–$1,000+ additional** |

### Per workload account (prod/staging/dev/sandbox)

| Service | Cost driver | Typical / month |
|---|---|---|
| VPC | Free | $0 |
| NAT Gateway | $0.045/hour per gateway + $0.045/GB | **$96/account** (3 AZs × $32/mo) — use `single_nat_gateway = true` for $32 in non-prod |
| Interface VPC endpoints | $7.30/AZ × 10 endpoints × 3 AZs | **$219/account** (largest baseline driver) |
| Gateway VPC endpoints (S3, DynamoDB) | Free | $0 |
| TGW attachment | $0.05/hour | $36 |
| Application Load Balancer | $22.50/month + $0.008/LCU-hr | $30–100 |
| ECS Fargate | $0.04048/vCPU-hr + $0.004445/GB-hr | Highly variable |
| Aurora db.r6g.large | $0.292/hour per instance | $213 per instance/month |
| Secrets Manager | $0.40/secret/month + $0.05/10k API calls | $5–20 |
| **Subtotal workload baseline** | | **$400–700 baseline + app compute** |

## Estimated monthly totals

### Medium scale (10 accounts, 1 region)

| Account class | Count | Per-account | Total |
|---|---|---|---|
| Management | 1 | $200 | $200 |
| Security | 1 | $300 | $300 |
| Log archive | 1 | $200 | $200 |
| Network | 1 | $150 | $150 |
| Shared services | 1 | $50 | $50 |
| Workloads (prod) | 1 | $700 | $700 |
| Workloads (staging) | 1 | $500 | $500 |
| Workloads (dev/sandbox) | 2 | $250 | $500 |
| **Total** | **10** | | **~$2,600** |

Add applications (RDS, ECS tasks, Lambda invocations, S3 storage) on top.

### Large scale (30+ accounts, 1 region)

| Account class | Count | Per-account | Total |
|---|---|---|---|
| Management + Security + Log + Network + Shared + Data-platform + Security-tools | 7 | avg $200 | $1,400 |
| BU workload accounts | 6 (2 BUs × prod/staging/dev) | avg $400 | $2,400 |
| Sandboxes | 4 | $100 | $400 |
| **Total** | **17 listed** | | **~$4,200** |

Large deployment with full BU expansion typically lands $5K–10K/mo baseline.

### Optional add-ons (off by default)

| Feature | Where to enable | Monthly cost |
|---|---|---|
| Network Firewall | `modules/network-firewall` | $855 per VPC where deployed |
| Client VPN | `modules/client-vpn` | $72/month endpoint + $36/user (8h/day) |
| AWS Shield Advanced | `modules/waf-baseline` flag | **$3,000/month minimum** (org-wide commit) |
| Aurora Global secondary cluster | `modules/aurora-global` | adds 1× primary cluster cost in secondary region |
| RDS Proxy | `modules/aurora-baseline` flag | ~$10–30/month per cluster |
| Macie sensitive-data jobs | scheduled job in security acct | $1/GB scanned |
| Lambda Insights | per-Lambda enablement | minimal (telemetry layer) |

## Where it can balloon (watch these)

| Risk | Why | Mitigation |
|---|---|---|
| CloudTrail S3 data events on every S3 object | Bucket with high object churn = millions of events | Filter selectors to specific buckets in `modules/cloudtrail` |
| Inspector v2 on a 1000-instance EC2 fleet | $1.25/instance/month | Tag-based exclusion for ephemeral workloads |
| Macie discovery jobs over large data lakes | $1/GB | Schedule for samples, not full scans |
| Athena queries over 10+ TB of CloudTrail history | $5/TB | Use partition projection (already configured); limit queries to time + region |
| Network Firewall always-on | $855/AZ-set/month | Only deploy in inspection VPCs that actually need stateful inspection |
| Aurora Global Database | doubles cluster cost | Only for active-passive DR; skip for active-passive-with-S3-snapshot |
| Multiple NAT Gateways in non-prod | $32 × 3 AZs × accounts | Set `single_nat_gateway = true` in dev/sandbox |
| VPC endpoints across many accounts | $7.30/AZ × 10 endpoints × 3 AZs | Selectively enable; gateway endpoints (S3/DynamoDB) are free |

## Cost controls already baked in

- **Cost Anomaly Detection** with $100 absolute threshold → SNS notifications (`modules/cost-management`)
- **Monthly org-wide budget** (default $50K) with 80% and 100% forecast notifications
- **Per-account budget alerts** at $50 (`modules/account-baseline`)
- **S3 lifecycle**: log-archive transitions to STANDARD_IA at 90 days, Glacier at 365 days
- **State buckets**: noncurrent versions expire at 90 days, incomplete multipart uploads at 7 days
- **Athena workgroup**: query result lifecycle 30 days
- **CloudWatch log retention**: 365 days default (configurable); `cloudwatch_log_group_class = "INFREQUENT_ACCESS"` available for ~50% cost reduction
- **Single-NAT-gateway flag** for non-prod (`var.single_nat_gateway = true`)
- **`Backup = true` tag selector** so backups only run on tagged resources

## How to drive cost down

1. **Use INFREQUENT_ACCESS log groups** in non-prod accounts → ~50% reduction in CW Logs storage
2. **Single NAT gateway in dev/sandbox** → saves $64/account/month
3. **Selectively enable VPC interface endpoints** — only the ones your apps actually use
4. **Tag-based Macie scanning** — don't scan everything; scan customer-data buckets only
5. **CloudTrail data events on specific buckets** — `event_selector` with bucket ARNs instead of `arn:aws:s3:::`
6. **Use CloudTrail Lake selectively** — keep the S3+Athena pipeline as the primary, Lake for high-cardinality investigations only
7. **Schedule Inspector** to skip ephemeral compute (CI runners, batch jobs) via tag exclusions
8. **Reserved capacity / Compute Savings Plans** for steady-state Aurora + Fargate workloads (not the template's responsibility; consume in your CUR)

## Comparison with alternative approaches

| Approach | Setup cost | Monthly cost (medium) | Lock-in |
|---|---|---|---|
| **This template** | 2–4 weeks engineering | $2.5K–4K | None (own the IaC) |
| **AWS Control Tower** | 1 week | $1K–2K (less Audit Manager / Lake) | High (CT migration is painful) |
| **AWS Landing Zone (legacy)** | 4–6 weeks | $1.5K–2.5K | Very high (deprecated by AWS) |
| **Cloud Adoption Framework + manual** | 6+ months | Variable | None (full custom) |

This template aims for the GitOps middle ground: Control Tower-equivalent
coverage with full Terraform ownership.
