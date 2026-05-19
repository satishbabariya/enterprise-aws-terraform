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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Short lowercase account name. | `string` | n/a | yes |
| <a name="input_max_secret_age_days"></a> [max\_secret\_age\_days](#input\_max\_secret\_age\_days) | Config rule threshold - alert if a secret has not been rotated in this many days. | `number` | `90` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rotation_lambda_role_arn"></a> [rotation\_lambda\_role\_arn](#output\_rotation\_lambda\_role\_arn) | IAM role ARN to attach to Secrets Manager rotation Lambdas |
| <a name="output_secrets_kms_key_arn"></a> [secrets\_kms\_key\_arn](#output\_secrets\_kms\_key\_arn) | KMS key ARN to use as kms\_key\_id on aws\_secretsmanager\_secret resources |
| <a name="output_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#output\_secrets\_kms\_key\_id) | KMS key ID for Secrets Manager |
<!-- END_TF_DOCS -->