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
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Short lowercase account name. Example: prod | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN to encrypt the state bucket and DynamoDB table. | `string` | n/a | yes |
| <a name="input_log_archive_bucket_arn"></a> [log\_archive\_bucket\_arn](#input\_log\_archive\_bucket\_arn) | ARN of the centralized log archive bucket for S3 access logging. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. Example: acme | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the bucket and table. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | S3 bucket ARN for Terraform state |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 bucket name for Terraform state |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | DynamoDB table name for state locking |
<!-- END_TF_DOCS -->