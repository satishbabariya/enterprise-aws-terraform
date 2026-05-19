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

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_allowlist"></a> [domain\_allowlist](#input\_domain\_allowlist) | Domains that egress is permitted to. Wildcard subdomains via .example.com syntax. Empty list means no allowlist enforcement. | `list(string)` | `[]` | no |
| <a name="input_enable_managed_rule_groups"></a> [enable\_managed\_rule\_groups](#input\_enable\_managed\_rule\_groups) | Attach AWS-managed threat-intel rule groups. | `bool` | `true` | no |
| <a name="input_firewall_subnet_ids"></a> [firewall\_subnet\_ids](#input\_firewall\_subnet\_ids) | Subnet IDs (one per AZ) where firewall endpoints will be placed. | `list(string)` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Customer-managed KMS key ARN for encrypting Network Firewall configuration (firewall + policy). Empty uses AWS-owned key. | `string` | `""` | no |
| <a name="input_log_destination_arn"></a> [log\_destination\_arn](#input\_log\_destination\_arn) | Kinesis Firehose ARN or CloudWatch Logs ARN for firewall flow + alert logs. | `string` | n/a | yes |
| <a name="input_log_destination_type"></a> [log\_destination\_type](#input\_log\_destination\_type) | S3, CloudWatchLogs, or KinesisDataFirehose | `string` | `"CloudWatchLogs"` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the firewall endpoints are deployed (typically a dedicated inspection VPC). | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_arn"></a> [firewall\_arn](#output\_firewall\_arn) | Network Firewall ARN |
| <a name="output_firewall_endpoint_ids"></a> [firewall\_endpoint\_ids](#output\_firewall\_endpoint\_ids) | Map of subnet ID to firewall endpoint ID - use in route tables |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | Network Firewall ID |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | Firewall policy ARN |
<!-- END_TF_DOCS -->