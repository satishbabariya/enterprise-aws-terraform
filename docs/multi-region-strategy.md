# Multi-Region Strategy

This template ships single-region by default (us-east-1 in all reference
deployments). Most enterprises eventually need a secondary region for one
of three reasons:

1. **Disaster recovery** — pilot-light or warm-standby in a second region for
   RTO < 4h.
2. **Active-active workloads** — global users need low-latency reads/writes
   from multiple regions.
3. **Compliance** — data residency requirements force regional sharding.

This doc covers the three patterns plus the modules that support them.

---

## Pattern A: Active-Passive (DR)

Primary region runs everything. Secondary region holds only:

- Replicated log archive (handled by `modules/log-archive-bucket` cross-region replication)
- Replicated backup vault (handled by `modules/aws-backup` cross-region copy)
- Aurora Global Database secondary cluster (handled by `modules/aurora-global`)
- Empty network: VPC + TGW provisioned but no compute, ready for failover

Cost: ~10% of primary (storage + Aurora secondary writer).
RPO: < 1 sec for Aurora Global, < 15 min for S3 replication, daily for AWS Backup.
RTO: 30 min - 4 hr depending on the failover automation you wire up.

**Module usage:**

```hcl
# In primary-region account root
module "primary_aurora" {
  source = "../../../modules/aurora-baseline"
  # ... primary cluster config
}

# In second account root pointing at secondary region
module "secondary_log_replica" {
  source = "../../../modules/log-archive-bucket"
  # replication target only
}

# In a "shared" root with both providers (aws.primary, aws.secondary)
module "aurora_global" {
  source = "../../../modules/aurora-global"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  # ... global cluster config
}
```

---

## Pattern B: Active-Active

Both regions serve production traffic. Requires:

- TGW in each region + cross-region TGW peering (`modules/tgw-peering`)
- Aurora Global with the secondary cluster promoted to writer-capable
  (using forwarding endpoints for writes from secondary region)
- Route53 latency-based routing or AWS Global Accelerator in front
- DynamoDB Global Tables (not yet a module - use `aws_dynamodb_table` with
  `replica` blocks in your workload code)
- S3 Cross-Region Replication for any shared assets

Cost: 2x primary. Operationally significant - every change must be tested
under split-brain conditions.

---

## Pattern C: Region-Sharded (Data Residency)

Customers in region X get their data in region X. Different from Pattern B
because there is no cross-region data replication - regions are independent.

Implementation: deploy `large/accounts/bu-<region>/` per shard, each with its
own network, workload accounts, and data. Share only the management +
security + log-archive accounts via Org-level services that operate globally.

---

## Provisioning a Secondary Region

### Step 1: Provider configuration

In any account root that touches both regions, add a provider alias:

```hcl
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/${var.org_name}-${var.account_name}-terraform-ci"
  }

  default_tags { tags = local.common_tags }
}
```

### Step 2: Bootstrap state for the secondary region (one-time)

State buckets are region-local. Run the bootstrap module a second time
with `region = "us-west-2"` and a different bucket name suffix.

### Step 3: Mirror foundation modules to secondary

Create `medium/accounts/network-secondary/` (or `large/accounts/network-us-west-2/`)
calling the same `modules/vpc` and `modules/tgw-hub` with `region = "us-west-2"`
and a non-overlapping CIDR.

### Step 4: Establish TGW peering

```hcl
module "tgw_peering" {
  source = "../../../modules/tgw-peering"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  primary_tgw_id      = data.terraform_remote_state.network_primary.outputs.tgw_id
  secondary_tgw_id    = data.terraform_remote_state.network_secondary.outputs.tgw_id
  secondary_region    = "us-west-2"
  name                = "us-east-1-to-us-west-2"
}
```

### Step 5: Add static routes to both TGW route tables

The peering attachment is bidirectional but route tables on each side need
explicit `aws_ec2_transit_gateway_route` entries for the peer's CIDRs.

---

## Failover Runbook

(Sketch - customize per workload before going live.)

1. **Detect** - Route53 health checks fire SNS → on-call paged.
2. **Promote** - For Aurora Global: `aws rds failover-global-cluster --target-db-cluster-identifier <secondary>`.
3. **Reroute** - Update Route53 weighted records to send 100% to secondary.
4. **Verify** - Run smoke tests against the secondary application endpoint.
5. **Post-mortem** - Once primary is back, decide whether to fail back (planned, off-hours) or run permanently from the former secondary.

---

## What This Template Does NOT Yet Include

- DynamoDB Global Tables module (handled inline by `aws_dynamodb_table` for now)
- Route53 Application Recovery Controller (ARC) routing controls - paid service, runbook driven
- Global Accelerator module
- App Mesh / cross-region service mesh - AWS App Mesh is deprecated, use Istio on EKS instead
- Cross-region IAM identity sharing (Identity Center is org-global, no work needed)

Open an issue if you need any of these added.
