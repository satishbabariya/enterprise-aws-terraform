<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | >= 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anomaly_alert_topic_arn"></a> [anomaly\_alert\_topic\_arn](#input\_anomaly\_alert\_topic\_arn) | SNS topic ARN where Cost Anomaly Detection sends alerts. | `string` | n/a | yes |
| <a name="input_budget_notification_emails"></a> [budget\_notification\_emails](#input\_budget\_notification\_emails) | Emails to notify on org-budget threshold breach. | `list(string)` | `[]` | no |
| <a name="input_cur_bucket_name"></a> [cur\_bucket\_name](#input\_cur\_bucket\_name) | S3 bucket name to receive the Cost & Usage Report. Should live in the log-archive account. | `string` | n/a | yes |
| <a name="input_cur_bucket_region"></a> [cur\_bucket\_region](#input\_cur\_bucket\_region) | Region of the CUR bucket. | `string` | `"us-east-1"` | no |
| <a name="input_monthly_org_budget_usd"></a> [monthly\_org\_budget\_usd](#input\_monthly\_org\_budget\_usd) | Org-wide monthly cost budget in USD. | `number` | `50000` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomaly_monitor_arn"></a> [anomaly\_monitor\_arn](#output\_anomaly\_monitor\_arn) | Cost Anomaly Detection monitor ARN |
| <a name="output_cur_report_name"></a> [cur\_report\_name](#output\_cur\_report\_name) | Cost & Usage Report name |
| <a name="output_org_budget_id"></a> [org\_budget\_id](#output\_org\_budget\_id) | Org-wide monthly budget ID |
<!-- END_TF_DOCS -->