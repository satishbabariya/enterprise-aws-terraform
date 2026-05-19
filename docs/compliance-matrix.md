# Compliance Coverage Matrix

## Service Controls

| Control                                              | CIS v3 | SOC2 | PCI-DSS v3.2 | HIPAA |
|------------------------------------------------------|:------:|:----:|:------------:|:-----:|
| CloudTrail (org-wide, multi-region)                  | YES    | YES  | YES          | YES   |
| CloudTrail log file validation                       | YES    | YES  | YES          | YES   |
| GuardDuty (all protections, org-wide)                | YES    | YES  | YES          | YES   |
| Security Hub (CIS/PCI/NIST standards)                | YES    | YES  | YES          | YES   |
| AWS Config recorder + aggregator                     | YES    | YES  | YES          | YES   |
| Macie (PII/sensitive data, org-wide)                 | --     | YES  | YES          | YES   |
| IAM Access Analyzer (org-wide)                       | YES    | YES  | YES          | YES   |
| Inspector v2 (EC2/ECR/Lambda)                        | --     | YES  | YES          | YES   |
| KMS encryption (EBS, S3, DynamoDB)                   | YES    | YES  | YES          | YES   |
| VPC flow logs -> immutable S3                        | YES    | YES  | YES          | YES   |
| S3 Object Lock on log archive (365+ days)            | --     | YES  | YES          | YES   |
| IMDSv2 required (SCP + per-account default)          | YES    | YES  | YES          | YES   |
| Root account usage denied (SCP)                      | YES    | YES  | YES          | YES   |
| Cannot leave organization (SCP)                      | YES    | YES  | YES          | YES   |
| IAM password policy (14+ chars, rotation)            | YES    | YES  | YES          | YES   |
| S3 Block Public Access (account + SCP)               | YES    | YES  | YES          | YES   |
| TLS enforced on log bucket (bucket policy)           | YES    | YES  | YES          | YES   |
| IAM user creation denied in workloads (SCP)          | YES    | YES  | YES          | YES   |
| Unencrypted EBS/RDS denied (SCP)                     | YES    | YES  | YES          | YES   |

## SCP Coverage

| SCP                       | OU Scope                              |
|---------------------------|---------------------------------------|
| DenyRootActions           | Root (all OUs)                        |
| DenyLeaveOrganization     | Root (all OUs)                        |
| DenyNonApprovedRegions    | Root (all OUs)                        |
| DenyUnencryptedStorage    | Workloads OU                          |
| DenyIAMUserCreation       | Workloads OU                          |
| RequireIMDSv2             | Workloads OU                          |
| DenyS3PublicAccess        | (available to attach)                 |
| DenyVPCChanges            | (available to attach)                 |

## AWS Config Conformance Pack Template URIs

To enable AWS-managed conformance packs, add `aws_config_conformance_pack` resources
in `modules/aws-config/main.tf` referencing these S3 templates:

| Standard      | Template S3 URI                                                                                                                       |
|---------------|---------------------------------------------------------------------------------------------------------------------------------------|
| CIS v1.4 L2   | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml` |
| PCI-DSS 3.2.1 | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-PCI-DSS.yaml` |
| HIPAA         | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml` |
| NIST 800-53   | `s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-NIST-CSF.yaml` |
