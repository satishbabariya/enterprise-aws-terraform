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
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | Domains explicitly allowed - takes precedence over blocked\_domains and managed lists. | `list(string)` | `[]` | no |
| <a name="input_block_action"></a> [block\_action](#input\_block\_action) | BLOCK, ALERT, or BLOCK\_AND\_REPLY | `string` | `"BLOCK"` | no |
| <a name="input_blocked_domains"></a> [blocked\_domains](#input\_blocked\_domains) | Domains to block at the DNS resolver. Wildcards via *.example.com. | `list(string)` | `[]` | no |
| <a name="input_managed_domain_list_ids"></a> [managed\_domain\_list\_ids](#input\_managed\_domain\_list\_ids) | Map of AWS-managed domain list IDs to attach. Look up region-specific IDs with:<br>  aws route53resolver list-firewall-domain-lists<br>Example:<br>  {<br>    malware = "rslvr-fdl-2c46f2eced3c4abf"<br>    botnet  = "rslvr-fdl-1bdb8b1ce4654644"<br>  } | `map(string)` | `{}` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_ids"></a> [vpc\_ids](#input\_vpc\_ids) | VPC IDs to associate the DNS firewall rule group with. | `list(string)` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_group_arn"></a> [rule\_group\_arn](#output\_rule\_group\_arn) | DNS firewall rule group ARN |
| <a name="output_rule_group_id"></a> [rule\_group\_id](#output\_rule\_group\_id) | DNS firewall rule group ID |
| <a name="output_vpc_association_ids"></a> [vpc\_association\_ids](#output\_vpc\_association\_ids) | Map of VPC ID to association ID |
<!-- END_TF_DOCS -->