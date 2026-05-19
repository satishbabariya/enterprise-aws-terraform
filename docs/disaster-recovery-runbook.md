# Disaster Recovery Runbook

Concrete, named-step procedures for the failure scenarios this template
defends against. Each section lists: detection signal → who pages → exact
commands → verification.

`docs/multi-region-strategy.md` covers *architecture*. This doc covers
*the moment something is on fire*.

> All commands assume the operator has assumed the appropriate `BreakGlassAdmin`
> permission set via IAM Identity Center. Substitute your org's role name.

---

## Scenario 1: Aurora primary failure (single-region cluster)

### Detection signal

- CloudWatch alarm `<cluster>-writer-unhealthy` (auto-created by Aurora)
- Or app-level: connection failures to `<cluster>.cluster-XXX.region.rds.amazonaws.com`

### Pages

- On-call DBA (high-severity SNS topic)
- Service owner (via SNS subscription on the SecurityHub `high` topic)

### Procedure

Aurora handles writer→reader failover automatically. **Most failures
resolve in 30–60 seconds without intervention.** If it doesn't:

```bash
# 1. Confirm cluster state
aws rds describe-db-clusters \
  --db-cluster-identifier <cluster-id> \
  --query 'DBClusters[0].{Status:Status,Endpoint:Endpoint,Members:DBClusterMembers}'

# 2. If a reader is healthy, force failover to it
aws rds failover-db-cluster \
  --db-cluster-identifier <cluster-id> \
  --target-db-instance-identifier <reader-instance-id>

# 3. Wait for the reader to become writer (~30s)
aws rds wait db-cluster-available --db-cluster-identifier <cluster-id>

# 4. App should reconnect automatically (Aurora writer endpoint DNS updates).
#    If it doesn't, the app is caching DNS too long - fix this for next time.
```

### Verification

```bash
aws rds describe-db-clusters --db-cluster-identifier <cluster-id> \
  --query 'DBClusters[0].DBClusterMembers[?IsClusterWriter==`true`].DBInstanceIdentifier' \
  --output text
# Should print the previously-reader instance ID
```

### Post-incident

- New writer is now the previously-promoted reader. Original failed
  instance is in `failed` or `incompatible-restore` state.
- AWS RDS will auto-replace the failed instance within ~30 minutes.
- If you used `modules/aurora-baseline` with `multi_az = true` (default),
  no manual replacement needed.

---

## Scenario 2: Aurora Global Database — primary region failure

### Detection signal

- Primary region API endpoints unreachable for > 5 minutes
- Route53 health check failing on the primary region API endpoint

### Pages

- Incident commander
- DBA + app team lead
- Communications lead

### Procedure

Promoting the secondary cluster is **destructive** to the global database
relationship — the secondary cluster becomes a standalone primary, and the
global cluster wrapper is dissolved. You can't easily reverse this.

```bash
# 1. CONFIRM the primary is genuinely down, not a partial network issue.
#    A premature failover during a recoverable outage is the most common
#    Aurora Global mistake. Wait 15+ minutes before failing over.

# 2. Promote the secondary cluster (this is the destructive step):
aws rds failover-global-cluster \
  --global-cluster-identifier <global-cluster-id> \
  --target-db-cluster-identifier arn:aws:rds:<secondary-region>:<account>:cluster:<secondary-cluster-id>

# This takes 1-3 minutes. The secondary cluster's writer endpoint becomes
# writable. The primary cluster (if still reachable) becomes detached.

# 3. Update Route53 (or your service discovery) to point apps at the new writer
aws route53 change-resource-record-sets --hosted-zone-id <zone> --change-batch '{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "db.example.com",
      "Type": "CNAME",
      "TTL": 60,
      "ResourceRecords": [{"Value": "<secondary-cluster-writer-endpoint>"}]
    }
  }]
}'

# 4. Restart apps that have stale connections to old endpoint
```

### Verification

```bash
# Confirm new writer is in secondary region
aws rds describe-db-clusters --db-cluster-identifier <secondary-cluster-id> \
  --region <secondary-region> \
  --query 'DBClusters[0].DBClusterMembers[?IsClusterWriter==`true`]'

# Smoke-test via app:
curl -fsS https://api.example.com/healthz
```

### Post-incident

- The original primary cluster (in failed region) is **orphaned**.
  Manually clean it up once you're confident in the new primary.
- Re-establish a new global cluster pointing at the now-primary
  (formerly-secondary) with a fresh secondary in a different region.
  This takes ~30 min to initial replication catch-up.

---

## Scenario 3: Log archive bucket unreachable / corrupted

### Detection signal

- CloudWatch alarm `<org>-cloudtrail-logging-stopped` fires
  (the trail-stopped alarm wired in `modules/cloudtrail`)
- CloudTrail console shows delivery errors
- S3 PutObject API failing for `cloudtrail.amazonaws.com` principal

### Pages

- Security on-call (critical SNS topic)
- Cloud platform team

### Procedure

The log archive is the audit source of truth. If it's down, you need to:
1. Continue capturing audit events (don't lose them)
2. Restore the log archive
3. Backfill any gap

```bash
# 1. Confirm the bucket is the issue (not CloudTrail role permissions)
aws s3 ls s3://<log-archive-bucket>/cloudtrail/
# If this fails with 403/404 etc, the bucket is genuinely broken

# 2. Switch CloudTrail to a temporary backup bucket (must already exist or
#    create one with correct CloudTrail bucket policy)
aws cloudtrail update-trail \
  --name <org-trail-name> \
  --s3-bucket-name <emergency-bucket-name>

# 3. If the original bucket is recoverable (e.g., accidentally deleted
#    objects), restore from cross-region replica (if enabled via
#    var.replica_bucket_arn):
aws s3 sync s3://<replica-bucket>/ s3://<log-archive-bucket>/ \
  --source-region <secondary-region>

# 4. If S3 Object Lock retention is intact, deleted objects since the
#    lock period are recoverable via versioning:
aws s3api list-object-versions --bucket <log-archive-bucket> \
  --prefix cloudtrail/ \
  | jq '.DeleteMarkers[] | .Key + " " + .VersionId'
# Then aws s3api delete-object --version-id <id> on each marker to undelete

# 5. Switch CloudTrail back to the original bucket after recovery
aws cloudtrail update-trail \
  --name <org-trail-name> \
  --s3-bucket-name <log-archive-bucket>
```

### Verification

```bash
# Confirm new events are landing
aws s3 ls s3://<log-archive-bucket>/cloudtrail/AWSLogs/<account>/CloudTrail/<region>/$(date +%Y/%m/%d)/
# Should show today's date prefix populated

# Confirm CIS metric filters still firing
aws cloudwatch get-metric-statistics \
  --namespace CloudTrailMetrics \
  --metric-name console_signin_no_mfa \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 --statistics Sum
```

### Post-incident

- Document the gap in audit trail (start time, end time) for compliance.
  Object Lock retention guarantees no tampering; gaps in delivery are
  visible in CloudTrail Lake.
- If gap > 1 hour, file with the Security team for incident response review.

---

## Scenario 4: IAM Identity Center down / locked out

### Detection signal

- Every operator getting "Unable to assume role" via Identity Center portal
- AWS Service Health Dashboard reports Identity Center API issues

### Pages

- Platform on-call
- Security (incident commander)

### Procedure

Identity Center is a regional service. The control plane is in your home
region. If that region is down:

```bash
# 1. Use the BreakGlassAdmin permission set if Identity Center responds
#    but specific permission sets are broken:
#    The break-glass role assumption triggers the CloudWatch alarm
#    <org>-break-glass-used (wired via modules/identity-center).

# 2. If Identity Center itself is down, fall back to the OIDC trust:
#    GitHub Actions can still assume the per-account TerraformCIRole.
#    Operators can manually trigger a workflow that runs aws CLI commands
#    on their behalf:
gh workflow run "Terraform Apply" --field scale=medium --field confirm=APPLY

# 3. As a last resort, fall back to the management account root user
#    (you should have MFA + a long random password sealed in a vault).
#    Use this only if all other paths are unavailable.

# 4. If a specific permission set is broken, recreate it via Terraform:
cd medium/accounts/management
terraform apply -target=module.identity_center
```

### Verification

```bash
# List active SSO sessions (after recovery)
aws sso-admin list-account-assignments \
  --instance-arn <sso-instance-arn> \
  --account-id <test-account> \
  --permission-set-arn <test-ps-arn>

# Confirm break-glass alarm did/didn't fire
aws cloudwatch describe-alarms --alarm-names <org>-break-glass-used \
  --query 'MetricAlarms[0].StateValue'
```

### Post-incident

- Every break-glass assumption requires a post-incident review within 24
  hours documenting why managed paths didn't suffice.
- File any Identity Center-specific issue with AWS support.

---

## Scenario 5: Region-wide AWS outage (your home region)

### Detection signal

- AWS Service Health Dashboard reports multiple services degraded in
  your home region
- Your monitoring sees broad-scope failures across services (not
  scoped to a single service or AZ)

### Pages

- Incident commander
- Service owners across all impacted workloads
- Communications + comms-to-customers

### Procedure

This is the worst-case. Most enterprises plan for it but rarely execute.
The template is configured for active-passive with a secondary region —
use it:

```bash
# 1. CONFIRM the outage. Check:
#    - https://health.aws.amazon.com/health/status
#    - Multiple services impacted (not just RDS or just S3)
#    - Multiple AZs affected (single-AZ is not a region outage)

# 2. Notify the org. The CloudTrail-Lake region-replication may itself
#    be impacted - rely on out-of-band comms (PagerDuty, Slack, phone).

# 3. Fail over workloads region-by-region in this order:
#    a. Aurora Global Database (Scenario 2 procedure)
#    b. Route53 weighted records or ARC routing controls (manual update)
#    c. Verify secondary VPC + EKS/ECS clusters can accept traffic
#    d. Restart application services in the secondary region

# 4. CloudTrail / Security Hub / GuardDuty are still working in the
#    secondary region from their own regional endpoints. No action needed.

# 5. Capture incident timeline for AWS post-mortem and your own
#    compliance reporting (SOC 2 / HIPAA require documented incident
#    response for outages affecting protected data).
```

### Verification

```bash
# Confirm app traffic is hitting secondary region
curl -fsS https://api.example.com/healthz \
  -H 'X-Debug-Region: true' | grep -i "region: <secondary>"

# Confirm Aurora secondary is now writable
aws rds describe-db-clusters --db-cluster-identifier <secondary-cluster> \
  --region <secondary-region> \
  --query 'DBClusters[0].Engine,DBClusters[0].DatabaseName'
```

### Post-incident

- Don't fail back to primary region until AWS declares the outage fully
  resolved and you've validated for at least 24 hours.
- Re-establish the global cluster relationship (Scenario 2 post-incident).
- Document the RTO (recovery time objective) actual vs. target — feed
  this back into compute capacity planning.

---

## Scenario 6: Compromised IAM role / key exposed

### Detection signal

- GuardDuty finding: `UnauthorizedAccess:IAM*` or `Recon:IAMUser/MaliciousIPCaller`
- The auto-quarantine Lambda (`modules/guardduty-auto-remediation`) has
  already applied a block-all SG to the affected EC2 instance, but
  the IAM role/key itself needs human action.

### Pages

- Security on-call (critical SNS)
- Service owner

### Procedure

```bash
# 1. CONFIRM the finding isn't a false positive. Check GuardDuty severity
#    and the specific resource:
aws guardduty get-findings --detector-id <id> --finding-ids <finding-id>

# 2. If it's a long-lived access key (which should be SCP-blocked but verify):
aws iam list-access-keys --user-name <user>
aws iam update-access-key --user-name <user> --access-key-id <key> --status Inactive

# 3. If it's an assumed-role session, you can't revoke individual STS
#    sessions. Instead, attach an AWSRevokeOlderSessions policy to the
#    role to invalidate all sessions older than NOW:
aws iam attach-role-policy \
  --role-name <compromised-role> \
  --policy-arn arn:aws:iam::aws:policy/AWSDenyAll
# This effectively kills the role; remove the deny once you've rotated
# the role's permissions appropriately.

# 4. Rotate any secrets the role had access to:
aws secretsmanager rotate-secret --secret-id <secret-arn>

# 5. Review CloudTrail Lake for the role's recent activity:
aws cloudtrail start-query --query-statement "
  SELECT eventTime, eventName, sourceIPAddress, awsRegion, errorCode
  FROM <event-data-store>
  WHERE userIdentity.arn = 'arn:aws:sts::<account>:assumed-role/<role-name>/*'
    AND eventTime > timestamp '$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)'
  ORDER BY eventTime DESC
"
```

### Verification

```bash
# Confirm role is denied
aws sts get-caller-identity  # from a session that previously used the role - should fail

# Confirm no new findings on the role
aws guardduty list-findings --detector-id <id> \
  --finding-criteria '{"Criterion":{"resource.accessKeyDetails.principalId":{"Eq":["<principal-id>"]}}}'
```

### Post-incident

- File a Security Hub custom finding documenting the incident.
- If the breach involved customer data: legal + breach notification
  obligations per your compliance scope (PCI DSS notify within 72 hours,
  HIPAA notify within 60 days).
- Run an Audit Manager assessment to verify all related controls held up.

---

## Practice these scenarios

A runbook nobody has run is a fiction. Schedule:

- **Aurora failover drill**: quarterly. Use a staging cluster. Time it.
- **Region failover drill**: annually. Plan for 1 day of effort + 1 week of post-incident write-ups.
- **Break-glass drill**: monthly. Have on-call assume the role + confirm
  the SNS notification arrived in PagerDuty + Slack.
- **Log archive recovery drill**: annually. Restore a deleted object
  via versioning to verify Object Lock and replication are sound.

Use AWS Fault Injection Simulator (`modules/chaos-engineering`) to run
some of these automatically rather than manually. The `az_failure`
template simulates a single-AZ blackhole; the `rds_failover` template
forces an Aurora failover. Schedule them in non-prod against tagged
resources (the `ChaosEligible` tag is enforced via FIS target selector).
