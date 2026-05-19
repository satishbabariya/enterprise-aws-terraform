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
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Private hosted zone name. Example: prod.acme.internal | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to associate with the private hosted zone. | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | Route53 name servers |
| <a name="output_zone_arn"></a> [zone\_arn](#output\_zone\_arn) | Route53 private hosted zone ARN |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route53 private hosted zone ID |
<!-- END_TF_DOCS -->