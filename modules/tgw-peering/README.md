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
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | >= 5.0 |
| <a name="provider_aws.secondary"></a> [aws.secondary](#provider\_aws.secondary) | >= 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name tag for the peering attachment. | `string` | n/a | yes |
| <a name="input_primary_tgw_id"></a> [primary\_tgw\_id](#input\_primary\_tgw\_id) | TGW ID in the primary region (provider aws.primary). | `string` | n/a | yes |
| <a name="input_secondary_account_id"></a> [secondary\_account\_id](#input\_secondary\_account\_id) | Account ID owning the secondary TGW. If same as primary, leave empty. | `string` | `""` | no |
| <a name="input_secondary_region"></a> [secondary\_region](#input\_secondary\_region) | AWS region for the secondary TGW. | `string` | n/a | yes |
| <a name="input_secondary_tgw_id"></a> [secondary\_tgw\_id](#input\_secondary\_tgw\_id) | TGW ID in the secondary region (provider aws.secondary). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attachment_id"></a> [attachment\_id](#output\_attachment\_id) | Peering attachment ID (use on both sides for route table associations) |
<!-- END_TF_DOCS -->