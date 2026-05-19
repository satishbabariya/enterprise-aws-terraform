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
| <a name="input_architectures"></a> [architectures](#input\_architectures) | x86\_64 or arm64 | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_dead_letter_topic_arn"></a> [dead\_letter\_topic\_arn](#input\_dead\_letter\_topic\_arn) | SNS topic to receive async invocation failures. | `string` | `""` | no |
| <a name="input_enable_lambda_insights"></a> [enable\_lambda\_insights](#input\_enable\_lambda\_insights) | Attach the Lambda Insights extension layer (enhanced CloudWatch metrics: CPU, memory, network, disk). | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables. Sensitive values should reference Secrets Manager via AWS Lambda extensions. | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the deployment package zip on the executor filesystem. Use null when source\_image is set. | `string` | `null` | no |
| <a name="input_function_url_authorization_type"></a> [function\_url\_authorization\_type](#input\_function\_url\_authorization\_type) | AWS\_IAM (signed requests required) or NONE (public). | `string` | `"AWS_IAM"` | no |
| <a name="input_function_url_enabled"></a> [function\_url\_enabled](#input\_function\_url\_enabled) | Create a Lambda Function URL (public HTTPS endpoint). Use AWS\_IAM auth in any non-trivial case. | `bool` | `false` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function handler (e.g., index.handler). | `string` | n/a | yes |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI for container Lambda. Empty for zip-based. | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for environment variable encryption + log encryption. | `string` | n/a | yes |
| <a name="input_lambda_insights_layer_arn"></a> [lambda\_insights\_layer\_arn](#input\_lambda\_insights\_layer\_arn) | Lambda Insights extension layer ARN. Region-specific - find at https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cloudwatch-Lambda-Insights-extension-versions.html | `string` | `""` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | Lambda layer ARNs to attach (max 5). Caller-supplied layers will be combined with the Insights layer if enable\_lambda\_insights = true. | `list(string)` | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Log retention. | `number` | `365` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Memory in MB. | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Lambda function name. | `string` | n/a | yes |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | IAM permissions boundary ARN for the execution role. Caps what additional policies the role can grant. | `string` | `""` | no |
| <a name="input_publish_version"></a> [publish\_version](#input\_publish\_version) | Publish a new immutable version on each apply. Required for alias-based deployments. | `bool` | `false` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Concurrency reservation. -1 for unreserved. | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Function runtime. | `string` | `"python3.12"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds. | `number` | `30` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Security group IDs. Required if vpc\_subnet\_ids is set. | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Private subnet IDs. Empty to run outside a VPC. | `list(string)` | `[]` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | Execution role ARN - attach additional policies via aws\_iam\_role\_policy\_attachment from the caller |
| <a name="output_execution_role_name"></a> [execution\_role\_name](#output\_execution\_role\_name) | Execution role name |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | Lambda function ARN |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Lambda function name |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | Function URL (empty if disabled). Public HTTPS endpoint - signed requests required if authorization\_type = AWS\_IAM. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Lambda CloudWatch log group name |
| <a name="output_version"></a> [version](#output\_version) | Latest published version (only meaningful if publish\_version = true) |
<!-- END_TF_DOCS -->