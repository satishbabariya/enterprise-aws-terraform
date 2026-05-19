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
| <a name="input_alarms_sns_topic_arn"></a> [alarms\_sns\_topic\_arn](#input\_alarms\_sns\_topic\_arn) | SNS topic to receive CIS metric filter alarms (typically the central 'high' severity topic). Empty disables alarm wiring. | `string` | `""` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Log group storage class: STANDARD or INFREQUENT\_ACCESS. IA is ~50% cheaper for archive logs that are rarely queried in real time. | `string` | `"STANDARD"` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Retention for the trail's CloudWatch log group. | `number` | `365` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Create a CloudWatch log group + IAM role and ship trail events to it. Required for CIS metric filter alarms. | `bool` | `true` | no |
| <a name="input_enable_delivery_notification"></a> [enable\_delivery\_notification](#input\_enable\_delivery\_notification) | Create an SNS topic that CloudTrail publishes log-file-delivery notifications to (for SIEM integrations). | `bool` | `false` | no |
| <a name="input_enable_eventbridge_remediation"></a> [enable\_eventbridge\_remediation](#input\_enable\_eventbridge\_remediation) | Create EventBridge rules that route specific CloudTrail events (public SG ingress, IAM key creation) for downstream auto-remediation. | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for CloudTrail log encryption (primary region key, or multi-region key primary ARN). | `string` | n/a | yes |
| <a name="input_log_archive_bucket_name"></a> [log\_archive\_bucket\_name](#input\_log\_archive\_bucket\_name) | Name of the centralized log-archive S3 bucket. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cis_alarm_arns"></a> [cis\_alarm\_arns](#output\_cis\_alarm\_arns) | Map of CIS rule key to CloudWatch alarm ARN |
| <a name="output_cis_metric_filter_names"></a> [cis\_metric\_filter\_names](#output\_cis\_metric\_filter\_names) | Names of CIS-mapped metric filters |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | CloudWatch log group receiving trail events (empty if disabled) |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | CloudWatch log group name |
| <a name="output_delivery_sns_topic_arn"></a> [delivery\_sns\_topic\_arn](#output\_delivery\_sns\_topic\_arn) | SNS topic CloudTrail publishes log-file-delivery notifications to (empty if disabled) |
| <a name="output_eventbridge_rule_arns"></a> [eventbridge\_rule\_arns](#output\_eventbridge\_rule\_arns) | EventBridge rule ARNs - subscribe Lambdas or step functions to these for auto-remediation |
| <a name="output_trail_arn"></a> [trail\_arn](#output\_trail\_arn) | CloudTrail trail ARN |
| <a name="output_trail_name"></a> [trail\_name](#output\_trail\_name) | CloudTrail trail name |
<!-- END_TF_DOCS -->