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
| <a name="input_container_insights_mode"></a> [container\_insights\_mode](#input\_container\_insights\_mode) | Container Insights mode:<br>- "enhanced" - newer mode (Nov 2024+) with per-task/service granularity + Application Signals support<br>- "enabled"  - legacy mode (cluster-level metrics only)<br>- "disabled" - off<br>Enhanced is recommended for prod - the data is what you need during incident response. | `string` | `"enhanced"` | no |
| <a name="input_fargate_capacity_providers"></a> [fargate\_capacity\_providers](#input\_fargate\_capacity\_providers) | Use FARGATE and/or FARGATE\_SPOT. | `list(string)` | <pre>[<br>  "FARGATE",<br>  "FARGATE_SPOT"<br>]</pre> | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for CloudWatch log encryption + ECS Exec session encryption. | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Cluster log group retention. | `number` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | ECS cluster name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ECS cluster ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | ECS cluster name |
| <a name="output_exec_log_group_name"></a> [exec\_log\_group\_name](#output\_exec\_log\_group\_name) | Log group for ECS Exec sessions |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | Default task execution role ARN |
<!-- END_TF_DOCS -->