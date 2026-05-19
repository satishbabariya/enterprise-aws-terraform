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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID of the account being baselined. | `string` | n/a | yes |
| <a name="input_budget_notification_emails"></a> [budget\_notification\_emails](#input\_budget\_notification\_emails) | Email addresses to notify on budget threshold breach. | `list(string)` | `[]` | no |
| <a name="input_iam_account_password_policy"></a> [iam\_account\_password\_policy](#input\_iam\_account\_password\_policy) | IAM account password policy settings. | <pre>object({<br>    minimum_password_length        = number<br>    require_lowercase_characters   = bool<br>    require_uppercase_characters   = bool<br>    require_numbers                = bool<br>    require_symbols                = bool<br>    allow_users_to_change_password = bool<br>    max_password_age               = number<br>    password_reuse_prevention      = number<br>    hard_expiry                    = bool<br>  })</pre> | <pre>{<br>  "allow_users_to_change_password": true,<br>  "hard_expiry": false,<br>  "max_password_age": 90,<br>  "minimum_password_length": 14,<br>  "password_reuse_prevention": 24,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true<br>}</pre> | no |
| <a name="input_monthly_budget_amount_usd"></a> [monthly\_budget\_amount\_usd](#input\_monthly\_budget\_amount\_usd) | Monthly cost budget alert threshold in USD. | `number` | `50` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to taggable resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_public_access_block_id"></a> [s3\_public\_access\_block\_id](#output\_s3\_public\_access\_block\_id) | ID of the S3 account public access block |
<!-- END_TF_DOCS -->