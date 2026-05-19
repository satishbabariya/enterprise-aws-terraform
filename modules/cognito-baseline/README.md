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
| <a name="input_advanced_security_mode"></a> [advanced\_security\_mode](#input\_advanced\_security\_mode) | OFF, AUDIT, or ENFORCED. ENFORCED enables compromised-credentials checks + risk-based auth. | `string` | `"ENFORCED"` | no |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | Allowed OAuth callback URLs. | `list(string)` | `[]` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | ACTIVE or INACTIVE | `string` | `"ACTIVE"` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | Allowed OAuth logout URLs. | `list(string)` | `[]` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | OFF, ON, or OPTIONAL | `string` | `"ON"` | no |
| <a name="input_name"></a> [name](#input\_name) | User pool name. | `string` | n/a | yes |
| <a name="input_password_minimum_length"></a> [password\_minimum\_length](#input\_password\_minimum\_length) | Minimum password length. | `number` | `14` | no |
| <a name="input_ses_source_arn"></a> [ses\_source\_arn](#input\_ses\_source\_arn) | Verified SES identity ARN for sending Cognito emails. Empty uses default Cognito sender (rate-limited). | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_client_id"></a> [app\_client\_id](#output\_app\_client\_id) | App client ID |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | Cognito user pool ARN |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | Cognito user pool endpoint |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito user pool ID |
<!-- END_TF_DOCS -->