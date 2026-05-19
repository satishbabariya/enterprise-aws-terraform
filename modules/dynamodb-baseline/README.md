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
| <a name="input_additional_attributes"></a> [additional\_attributes](#input\_additional\_attributes) | Additional attributes referenced by GSIs/LSIs. Each: { name, type (S/N/B) }. Only index-key attributes need to be declared. | <pre>list(object({<br>    name = string<br>    type = string<br>  }))</pre> | `[]` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | PAY\_PER\_REQUEST or PROVISIONED. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_enable_streams"></a> [enable\_streams](#input\_enable\_streams) | Enable DynamoDB Streams. | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Global Secondary Indexes. Each entry:<br>  name, hash\_key, range\_key (optional), projection\_type (ALL/KEYS\_ONLY/INCLUDE),<br>  non\_key\_attributes (when projection\_type = INCLUDE), read/write\_capacity (PROVISIONED only). | <pre>list(object({<br>    name               = string<br>    hash_key           = string<br>    range_key          = optional(string)<br>    projection_type    = optional(string, "ALL")<br>    non_key_attributes = optional(list(string), [])<br>    read_capacity      = optional(number)<br>    write_capacity     = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_global_table_regions"></a> [global\_table\_regions](#input\_global\_table\_regions) | Other AWS regions to replicate the table to via Global Tables v2. Empty disables. Replicas must use the same KMS key alias (caller responsibility). | `list(string)` | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Partition key name. | `string` | n/a | yes |
| <a name="input_hash_key_type"></a> [hash\_key\_type](#input\_hash\_key\_type) | S/N/B | `string` | `"S"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for SSE. | `string` | n/a | yes |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Local Secondary Indexes. Must be defined at table creation; cannot be added later. | <pre>list(object({<br>    name               = string<br>    range_key          = string<br>    projection_type    = optional(string, "ALL")<br>    non_key_attributes = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | DynamoDB table name. | `string` | n/a | yes |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | Sort key name. Empty for none. | `string` | `""` | no |
| <a name="input_range_key_type"></a> [range\_key\_type](#input\_range\_key\_type) | S/N/B | `string` | `"S"` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES, KEYS\_ONLY | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute"></a> [ttl\_attribute](#input\_ttl\_attribute) | TTL attribute name. Empty disables TTL. | `string` | `""` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | Stream ARN (empty if streams not enabled) |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | DynamoDB table ARN |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | DynamoDB table name |
<!-- END_TF_DOCS -->