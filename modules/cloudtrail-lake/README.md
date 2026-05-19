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
| <a name="input_include_lambda_data_events"></a> [include\_lambda\_data\_events](#input\_include\_lambda\_data\_events) | Include Lambda invoke events. | `bool` | `false` | no |
| <a name="input_include_management_events"></a> [include\_management\_events](#input\_include\_management\_events) | Include management events (control plane API calls). | `bool` | `true` | no |
| <a name="input_include_s3_data_events"></a> [include\_s3\_data\_events](#input\_include\_s3\_data\_events) | Include S3 object-level events (significant storage cost). | `bool` | `false` | no |
| <a name="input_is_organization_event_data_store"></a> [is\_organization\_event\_data\_store](#input\_is\_organization\_event\_data\_store) | Capture events from all accounts in the organization (recommended for centralized audit). | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for event data store encryption. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Event retention period in days. 7-year regulatory archive = 2555. | `number` | `2555` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_data_store_arn"></a> [event\_data\_store\_arn](#output\_event\_data\_store\_arn) | CloudTrail Lake Event Data Store ARN - query via aws cloudtrail start-query |
| <a name="output_event_data_store_name"></a> [event\_data\_store\_name](#output\_event\_data\_store\_name) | Event data store name |
<!-- END_TF_DOCS -->