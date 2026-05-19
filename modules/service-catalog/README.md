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
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_portfolio_provider"></a> [portfolio\_provider](#input\_portfolio\_provider) | Provider display name (typically the platform team). | `string` | `"Platform Team"` | no |
| <a name="input_products"></a> [products](#input\_products) | Map of approved products. Each product references a CloudFormation template<br>(S3 URL) and version. Add products for VPCs, ECS services, RDS instances,<br>etc. that developers can self-service through the AWS console. | <pre>map(object({<br>    description         = string<br>    owner               = string<br>    template_url        = string<br>    version_description = optional(string, "Initial version")<br>    distributor         = optional(string, "")<br>    support_email       = optional(string, "")<br>    support_url         = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_shared_with_principal_arns"></a> [shared\_with\_principal\_arns](#input\_shared\_with\_principal\_arns) | IAM principal ARNs allowed to launch products (typically SSO permission set ARNs for developer groups). | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_portfolio_arn"></a> [portfolio\_arn](#output\_portfolio\_arn) | Service Catalog portfolio ARN |
| <a name="output_portfolio_id"></a> [portfolio\_id](#output\_portfolio\_id) | Service Catalog portfolio ID |
| <a name="output_product_ids"></a> [product\_ids](#output\_product\_ids) | Map of product name to ID |
<!-- END_TF_DOCS -->