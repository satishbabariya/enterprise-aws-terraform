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
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | >= 5.0 |
| <a name="provider_aws.secondary"></a> [aws.secondary](#provider\_aws.secondary) | >= 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID owning the key (same on both regions for a multi-region key). | `string` | n/a | yes |
| <a name="input_additional_key_admins"></a> [additional\_key\_admins](#input\_additional\_key\_admins) | IAM ARNs allowed to administer the key. | `list(string)` | `[]` | no |
| <a name="input_additional_key_users"></a> [additional\_key\_users](#input\_additional\_key\_users) | IAM ARNs allowed to use the key for encrypt/decrypt. | `list(string)` | `[]` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Pending-deletion window in days (7-30). | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Key description. | `string` | n/a | yes |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | KMS alias (without 'alias/' prefix). Same alias is created in both regions. | `string` | n/a | yes |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | AWS service principals (e.g. cloudtrail.amazonaws.com) granted use of the key. Restricted via aws:SourceArn in the caller. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | Alias (same in both regions) |
| <a name="output_primary_key_arn"></a> [primary\_key\_arn](#output\_primary\_key\_arn) | Primary KMS key ARN (use in primary region resources) |
| <a name="output_primary_key_id"></a> [primary\_key\_id](#output\_primary\_key\_id) | Primary KMS key ID |
| <a name="output_secondary_key_arn"></a> [secondary\_key\_arn](#output\_secondary\_key\_arn) | Replica KMS key ARN (use in secondary region resources, e.g., CRR destination encryption) |
| <a name="output_secondary_key_id"></a> [secondary\_key\_id](#output\_secondary\_key\_id) | Replica KMS key ID |
<!-- END_TF_DOCS -->