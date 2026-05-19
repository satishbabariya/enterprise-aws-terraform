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
| <a name="input_athena_results_bucket_name"></a> [athena\_results\_bucket\_name](#input\_athena\_results\_bucket\_name) | Optional S3 bucket for Athena query results. If empty, a new bucket is created. | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for query result encryption. | `string` | n/a | yes |
| <a name="input_log_archive_bucket_name"></a> [log\_archive\_bucket\_name](#input\_log\_archive\_bucket\_name) | Name of the centralized log archive S3 bucket. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_query_result_retention_days"></a> [query\_result\_retention\_days](#input\_query\_result\_retention\_days) | How long to retain Athena query results. | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_glue_database_name"></a> [glue\_database\_name](#output\_glue\_database\_name) | Glue catalog database name |
| <a name="output_results_bucket_name"></a> [results\_bucket\_name](#output\_results\_bucket\_name) | Bucket where Athena query results land |
| <a name="output_workgroup_arn"></a> [workgroup\_arn](#output\_workgroup\_arn) | Athena workgroup ARN |
| <a name="output_workgroup_name"></a> [workgroup\_name](#output\_workgroup\_name) | Athena workgroup name |
<!-- END_TF_DOCS -->