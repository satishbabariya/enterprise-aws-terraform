<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_quarantine_findings"></a> [auto\_quarantine\_findings](#input\_auto\_quarantine\_findings) | GuardDuty finding types that trigger automatic resource quarantine (block-all SG attached to compromised EC2). | `list(string)` | <pre>[<br>  "Backdoor:EC2/C&CActivity.B!DNS",<br>  "Backdoor:EC2/Spambot",<br>  "CryptoCurrency:EC2/BitcoinTool.B!DNS",<br>  "Trojan:EC2/BlackholeTraffic",<br>  "Trojan:EC2/DriveBySourceTraffic!DNS",<br>  "Trojan:EC2/DropPoint!DNS",<br>  "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom",<br>  "UnauthorizedAccess:EC2/MetadataDNSRebind"<br>]</pre> | no |
| <a name="input_critical_alert_topic_arn"></a> [critical\_alert\_topic\_arn](#input\_critical\_alert\_topic\_arn) | SNS topic ARN for critical-severity GuardDuty findings. | `string` | n/a | yes |
| <a name="input_high_alert_topic_arn"></a> [high\_alert\_topic\_arn](#input\_high\_alert\_topic\_arn) | SNS topic ARN for high-severity findings. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_quarantine_rule_arn"></a> [auto\_quarantine\_rule\_arn](#output\_auto\_quarantine\_rule\_arn) | EventBridge rule ARN for auto-quarantine findings |
| <a name="output_critical_severity_rule_arn"></a> [critical\_severity\_rule\_arn](#output\_critical\_severity\_rule\_arn) | EventBridge rule ARN for critical findings |
| <a name="output_high_severity_rule_arn"></a> [high\_severity\_rule\_arn](#output\_high\_severity\_rule\_arn) | EventBridge rule ARN for high-severity findings |
| <a name="output_quarantine_lambda_arn"></a> [quarantine\_lambda\_arn](#output\_quarantine\_lambda\_arn) | ARN of the auto-quarantine Lambda |
<!-- END_TF_DOCS -->