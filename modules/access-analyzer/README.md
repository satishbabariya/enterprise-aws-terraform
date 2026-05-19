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
| <a name="input_analyzer_type"></a> [analyzer\_type](#input\_analyzer\_type) | ACCOUNT or ORGANIZATION. | `string` | `"ORGANIZATION"` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_analyzer_arn"></a> [analyzer\_arn](#output\_analyzer\_arn) | IAM Access Analyzer ARN |
| <a name="output_analyzer_name"></a> [analyzer\_name](#output\_analyzer\_name) | IAM Access Analyzer name |
<!-- END_TF_DOCS -->