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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Short lowercase account name. | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub org name for OIDC trust. | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repo name for OIDC trust. | `string` | n/a | yes |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | Description for the workload's general-purpose KMS key. | `string` | `"Workload account general-purpose KMS key"` | no |
| <a name="input_log_archive_bucket_arn"></a> [log\_archive\_bucket\_arn](#input\_log\_archive\_bucket\_arn) | ARN of the centralized log archive bucket. | `string` | n/a | yes |
| <a name="input_log_archive_bucket_name"></a> [log\_archive\_bucket\_name](#input\_log\_archive\_bucket\_name) | Name of the centralized log archive bucket. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the general-purpose KMS key |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the general-purpose KMS key |
| <a name="output_secrets_kms_key_arn"></a> [secrets\_kms\_key\_arn](#output\_secrets\_kms\_key\_arn) | KMS key for Secrets Manager secrets in this account |
| <a name="output_secrets_rotation_role_arn"></a> [secrets\_rotation\_role\_arn](#output\_secrets\_rotation\_role\_arn) | IAM role to attach to Secrets Manager rotation Lambdas |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Name of the per-account state bucket |
| <a name="output_terraform_ci_role_arn"></a> [terraform\_ci\_role\_arn](#output\_terraform\_ci\_role\_arn) | ARN of the CI role assumed by GitHub Actions |
<!-- END_TF_DOCS -->