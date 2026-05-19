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
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | ~> 5.0 |
| <a name="provider_aws.secondary"></a> [aws.secondary](#provider\_aws.secondary) | ~> 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention. | `number` | `30` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Initial DB name. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Deletion protection. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | aurora-postgresql or aurora-mysql | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version. Must be a Global Database-supported version. | `string` | n/a | yes |
| <a name="input_global_name"></a> [global\_name](#input\_global\_name) | Global cluster identifier. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | DB instance class. | `string` | `"db.r6g.large"` | no |
| <a name="input_instance_count_per_region"></a> [instance\_count\_per\_region](#input\_instance\_count\_per\_region) | Number of instances per region cluster. | `number` | `2` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master username. | `string` | `"dbadmin"` | no |
| <a name="input_primary_cluster_identifier"></a> [primary\_cluster\_identifier](#input\_primary\_cluster\_identifier) | Cluster identifier for the primary writer cluster. | `string` | n/a | yes |
| <a name="input_primary_db_subnet_group_name"></a> [primary\_db\_subnet\_group\_name](#input\_primary\_db\_subnet\_group\_name) | Existing DB subnet group in the primary region. | `string` | n/a | yes |
| <a name="input_primary_kms_key_arn"></a> [primary\_kms\_key\_arn](#input\_primary\_kms\_key\_arn) | KMS key ARN in the primary region. | `string` | n/a | yes |
| <a name="input_primary_vpc_security_group_ids"></a> [primary\_vpc\_security\_group\_ids](#input\_primary\_vpc\_security\_group\_ids) | Security groups in the primary region cluster. | `list(string)` | n/a | yes |
| <a name="input_secondary_cluster_identifier"></a> [secondary\_cluster\_identifier](#input\_secondary\_cluster\_identifier) | Cluster identifier for the secondary (read-only) cluster. | `string` | n/a | yes |
| <a name="input_secondary_db_subnet_group_name"></a> [secondary\_db\_subnet\_group\_name](#input\_secondary\_db\_subnet\_group\_name) | Existing DB subnet group in the secondary region. | `string` | n/a | yes |
| <a name="input_secondary_kms_key_arn"></a> [secondary\_kms\_key\_arn](#input\_secondary\_kms\_key\_arn) | KMS key ARN in the secondary region (must be a key in that region). | `string` | n/a | yes |
| <a name="input_secondary_vpc_security_group_ids"></a> [secondary\_vpc\_security\_group\_ids](#input\_secondary\_vpc\_security\_group\_ids) | Security groups in the secondary region cluster. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_cluster_id"></a> [global\_cluster\_id](#output\_global\_cluster\_id) | Global cluster ID |
| <a name="output_primary_endpoint"></a> [primary\_endpoint](#output\_primary\_endpoint) | Primary writer endpoint |
| <a name="output_primary_reader_endpoint"></a> [primary\_reader\_endpoint](#output\_primary\_reader\_endpoint) | Primary reader (load-balanced) endpoint |
| <a name="output_primary_secret_arn"></a> [primary\_secret\_arn](#output\_primary\_secret\_arn) | Secrets Manager ARN for the master password |
| <a name="output_secondary_reader_endpoint"></a> [secondary\_reader\_endpoint](#output\_secondary\_reader\_endpoint) | Secondary region reader endpoint - use for read traffic close to secondary-region clients |
<!-- END_TF_DOCS -->