<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audit_reader_external_id"></a> [audit\_reader\_external\_id](#input\_audit\_reader\_external\_id) | Optional external ID required by the AuditReader trust policy (defense in depth for cross-account trust). Empty disables. | `string` | `""` | no |
| <a name="input_audit_reader_principal_arns"></a> [audit\_reader\_principal\_arns](#input\_audit\_reader\_principal\_arns) | IAM principals (typically the security account's audit role ARN, or an SSO<br>permission set role pattern) that can assume the AuditReader role to query<br>archived logs read-only. Empty list disables the role creation.<br>Example: ["arn:aws:iam::222222222222:root"] | `list(string)` | `[]` | no |
| <a name="input_expected_cloudtrail_arn"></a> [expected\_cloudtrail\_arn](#input\_expected\_cloudtrail\_arn) | ARN of the org CloudTrail. If supplied, the bucket policy enforces that<br>CloudTrail's PutObject calls come from this exact trail via aws:SourceArn.<br>Construct as:<br>  arn:aws:cloudtrail:<region>:<management\_account\_id>:trail/<org\_name>-org-trail<br>Empty falls back to org-ID-only scoping (less strict). | `string` | `""` | no |
| <a name="input_expected_config_account_ids"></a> [expected\_config\_account\_ids](#input\_expected\_config\_account\_ids) | AWS account IDs allowed to write Config snapshots to this bucket via aws:SourceAccount. Typically the security account (Config aggregator) plus any per-account recorders. | `list(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for bucket encryption. | `string` | n/a | yes |
| <a name="input_management_account_id"></a> [management\_account\_id](#input\_management\_account\_id) | Management account ID - source account for the org CloudTrail writes (used in aws:SourceAccount condition). | `string` | n/a | yes |
| <a name="input_object_lock_retention_days"></a> [object\_lock\_retention\_days](#input\_object\_lock\_retention\_days) | WORM retention period in days. Minimum 365 for PCI-DSS/HIPAA. | `number` | `365` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | AWS Organizations organization ID. Used to scope the bucket policy. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_replica_bucket_arn"></a> [replica\_bucket\_arn](#input\_replica\_bucket\_arn) | ARN of a destination bucket in a secondary region for cross-region replication.<br>Must exist (create with a second copy of this module in the secondary region first,<br>or pass a pre-existing replica bucket). Empty disables replication. | `string` | `""` | no |
| <a name="input_replica_kms_key_arn"></a> [replica\_kms\_key\_arn](#input\_replica\_kms\_key\_arn) | KMS key ARN in the destination region for encrypting replicated objects. Required if replica\_bucket\_arn is set. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_audit_reader_role_arn"></a> [audit\_reader\_role\_arn](#output\_audit\_reader\_role\_arn) | ARN of the cross-account AuditReader role (empty if not created) |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the log archive S3 bucket |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of the log archive S3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the log archive S3 bucket |
<!-- END_TF_DOCS -->