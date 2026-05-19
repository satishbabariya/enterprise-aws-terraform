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
| <a name="input_backup_tag_key"></a> [backup\_tag\_key](#input\_backup\_tag\_key) | Tag key used to select resources for backup. Resources tagged with this key are included. | `string` | `"Backup"` | no |
| <a name="input_backup_tag_value"></a> [backup\_tag\_value](#input\_backup\_tag\_value) | Tag value to match for backup selection. | `string` | `"true"` | no |
| <a name="input_cross_region_copy_destination"></a> [cross\_region\_copy\_destination](#input\_cross\_region\_copy\_destination) | ARN of a backup vault in a secondary region for cross-region copies. Leave empty to disable. | `string` | `""` | no |
| <a name="input_daily_backup_retention_days"></a> [daily\_backup\_retention\_days](#input\_daily\_backup\_retention\_days) | How long to retain daily backups. | `number` | `35` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for backup vault encryption. | `string` | n/a | yes |
| <a name="input_monthly_backup_retention_days"></a> [monthly\_backup\_retention\_days](#input\_monthly\_backup\_retention\_days) | How long to retain monthly backups (regulatory archive). | `number` | `2555` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_vault_lock_changeable_for_days"></a> [vault\_lock\_changeable\_for\_days](#input\_vault\_lock\_changeable\_for\_days) | Cooling-off window (1-3 days) before Vault Lock becomes immutable. AWS minimum is 3. Set to 0 to skip Vault Lock entirely. | `number` | `3` | no |
| <a name="input_vault_lock_max_retention_days"></a> [vault\_lock\_max\_retention\_days](#input\_vault\_lock\_max\_retention\_days) | Maximum retention enforced by Vault Lock. | `number` | `36500` | no |
| <a name="input_vault_lock_min_retention_days"></a> [vault\_lock\_min\_retention\_days](#input\_vault\_lock\_min\_retention\_days) | Minimum retention enforced by Vault Lock. Set to 0 to disable Vault Lock (NOT recommended for prod). | `number` | `365` | no |
| <a name="input_weekly_backup_retention_days"></a> [weekly\_backup\_retention\_days](#input\_weekly\_backup\_retention\_days) | How long to retain weekly backups. | `number` | `365` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output\_backup\_role\_arn) | IAM role used by AWS Backup |
| <a name="output_plan_arn"></a> [plan\_arn](#output\_plan\_arn) | Backup plan ARN |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | Backup vault ARN |
| <a name="output_vault_name"></a> [vault\_name](#output\_vault\_name) | Backup vault name |
<!-- END_TF_DOCS -->