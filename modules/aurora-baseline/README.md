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
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security groups allowed to connect. | `list(string)` | `[]` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention. | `number` | `30` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Initial database name. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Deletion protection. | `bool` | `true` | no |
| <a name="input_enable_rds_proxy"></a> [enable\_rds\_proxy](#input\_enable\_rds\_proxy) | Provision RDS Proxy in front of the cluster. Connection pooling + IAM auth +<br>faster failover (seconds vs tens of seconds). Critical for Lambda/serverless.<br>Costs ~$0.015/vCPU-hour per node behind the proxy. | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | aurora-postgresql or aurora-mysql | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class. | `string` | `"db.r6g.large"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of cluster instances (writers + readers). | `number` | `2` | no |
| <a name="input_isolated_subnet_ids"></a> [isolated\_subnet\_ids](#input\_isolated\_subnet\_ids) | Isolated subnet IDs. | `list(string)` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for storage encryption. | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master username. | `string` | `"dbadmin"` | no |
| <a name="input_name"></a> [name](#input\_name) | Aurora cluster identifier. | `string` | n/a | yes |
| <a name="input_rds_proxy_idle_client_timeout_seconds"></a> [rds\_proxy\_idle\_client\_timeout\_seconds](#input\_rds\_proxy\_idle\_client\_timeout\_seconds) | Seconds an idle proxy client can hold a connection before recycling. | `number` | `1800` | no |
| <a name="input_rds_proxy_require_tls"></a> [rds\_proxy\_require\_tls](#input\_rds\_proxy\_require\_tls) | Require TLS between clients and proxy. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Cluster ARN |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Writer endpoint |
| <a name="output_port"></a> [port](#output\_port) | DB port |
| <a name="output_proxy_arn"></a> [proxy\_arn](#output\_proxy\_arn) | RDS Proxy ARN |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | RDS Proxy endpoint (empty if proxy not enabled). Connect via this in apps instead of the cluster endpoint. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | Reader (load-balanced) endpoint |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | Secrets Manager secret ARN for master credentials |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Cluster security group ID |
<!-- END_TF_DOCS -->