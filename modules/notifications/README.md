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
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for SNS topic encryption. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_pagerduty_critical_endpoint"></a> [pagerduty\_critical\_endpoint](#input\_pagerduty\_critical\_endpoint) | PagerDuty integration URL for the critical-severity topic. Empty disables. | `string` | `""` | no |
| <a name="input_pagerduty_high_endpoint"></a> [pagerduty\_high\_endpoint](#input\_pagerduty\_high\_endpoint) | PagerDuty integration URL for the high-severity topic. Empty disables. | `string` | `""` | no |
| <a name="input_severities"></a> [severities](#input\_severities) | Severity tiers to create SNS topics for. | `list(string)` | <pre>[<br>  "critical",<br>  "high",<br>  "medium",<br>  "low",<br>  "info"<br>]</pre> | no |
| <a name="input_slack_channel_id"></a> [slack\_channel\_id](#input\_slack\_channel\_id) | Slack channel ID to receive non-critical notifications. | `string` | `""` | no |
| <a name="input_slack_workspace_id"></a> [slack\_workspace\_id](#input\_slack\_workspace\_id) | AWS Chatbot workspace ID for Slack integration. Empty disables Chatbot setup. Run 'aws chatbot describe-slack-workspaces' to get this. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chatbot_role_arn"></a> [chatbot\_role\_arn](#output\_chatbot\_role\_arn) | Chatbot IAM role ARN (use in aws chatbot create-slack-channel-configuration) |
| <a name="output_event_bus_arn"></a> [event\_bus\_arn](#output\_event\_bus\_arn) | Central EventBridge bus ARN |
| <a name="output_event_bus_name"></a> [event\_bus\_name](#output\_event\_bus\_name) | Central EventBridge bus name |
| <a name="output_topic_arns"></a> [topic\_arns](#output\_topic\_arns) | Map of severity to SNS topic ARN |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | Map of severity to SNS topic name |
<!-- END_TF_DOCS -->