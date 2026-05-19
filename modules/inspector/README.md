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
| <a name="input_auto_enable"></a> [auto\_enable](#input\_auto\_enable) | Per-resource-type auto-enable for new org members. | <pre>object({<br>    ec2         = bool<br>    ecr         = bool<br>    lambda      = bool<br>    lambda_code = bool<br>  })</pre> | <pre>{<br>  "ec2": true,<br>  "ecr": true,<br>  "lambda": true,<br>  "lambda_code": true<br>}</pre> | no |
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | Security account ID that becomes Inspector delegated admin. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#output\_delegated\_admin\_account\_id) | Inspector delegated admin account ID |
<!-- END_TF_DOCS -->