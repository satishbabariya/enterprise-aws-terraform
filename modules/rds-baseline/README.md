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
| <a name="input_allocated_storage_gb"></a> [allocated\_storage\_gb](#input\_allocated\_storage\_gb) | Allocated storage in GB. | `number` | `100` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Allow Terraform to perform major version upgrades. Disabled by default to prevent accidental cross-version migration. | `bool` | `false` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security group IDs allowed to connect to this database. | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply modifications immediately instead of next maintenance window. Some changes still cause downtime. | `bool` | `false` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Automated backup retention. | `number` | `30` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred backup window (UTC). | `string` | `"03:00-05:00"` | no |
| <a name="input_blue_green_update_enabled"></a> [blue\_green\_update\_enabled](#input\_blue\_green\_update\_enabled) | Enable blue/green deployments for engine version upgrades - seconds of downtime instead of minutes. | `bool` | `false` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Initial database name. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine: postgres or mysql. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class (e.g., db.r6g.large). | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | Provisioned IOPS for gp3/io1/io2. Null uses AWS default. For gp3, only set if > 3000 baseline IOPS needed. | `number` | `null` | no |
| <a name="input_isolated_subnet_ids"></a> [isolated\_subnet\_ids](#input\_isolated\_subnet\_ids) | Isolated subnet IDs for the DB subnet group. | `list(string)` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for storage + Performance Insights encryption. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred maintenance window. | `string` | `"Mon:05:00-Mon:07:00"` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master username. | `string` | `"dbadmin"` | no |
| <a name="input_max_allocated_storage_gb"></a> [max\_allocated\_storage\_gb](#input\_max\_allocated\_storage\_gb) | Storage autoscaling max. | `number` | `1000` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Multi-AZ deployment. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | RDS instance identifier. | `string` | n/a | yes |
| <a name="input_storage_throughput"></a> [storage\_throughput](#input\_storage\_throughput) | Provisioned throughput in MB/s for gp3 storage. Null uses default (125 MB/s). Max 1000 MB/s. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | DB endpoint hostname |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | DB instance ARN |
| <a name="output_port"></a> [port](#output\_port) | DB port |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the Secrets Manager secret holding the master password |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group attached to the DB - reference from client SGs |
<!-- END_TF_DOCS -->