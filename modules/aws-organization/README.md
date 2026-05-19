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
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | Organization policy types to enable. | `list(string)` | <pre>[<br>  "SERVICE_CONTROL_POLICY",<br>  "TAG_POLICY"<br>]</pre> | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. Example: acme | `string` | n/a | yes |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | Map of OUs to create. Each entry: { name = string, parent\_key = string }.<br>Use parent\_key = "root" to attach directly to the org root.<br>Use the map key of another OU to nest under it. | <pre>map(object({<br>    name       = string<br>    parent_key = string<br>  }))</pre> | <pre>{<br>  "infrastructure": {<br>    "name": "Infrastructure",<br>    "parent_key": "root"<br>  },<br>  "security": {<br>    "name": "Security",<br>    "parent_key": "root"<br>  },<br>  "suspended": {<br>    "name": "Suspended",<br>    "parent_key": "root"<br>  },<br>  "workloads": {<br>    "name": "Workloads",<br>    "parent_key": "root"<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to taggable org resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_master_account_id"></a> [master\_account\_id](#output\_master\_account\_id) | Management account ID |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | AWS Organizations organization ARN |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | AWS Organizations organization ID |
| <a name="output_organizational_unit_arns"></a> [organizational\_unit\_arns](#output\_organizational\_unit\_arns) | Map of OU key to OU ARN |
| <a name="output_organizational_unit_ids"></a> [organizational\_unit\_ids](#output\_organizational\_unit\_ids) | Map of OU key to OU ID |
| <a name="output_root_id"></a> [root\_id](#output\_root\_id) | Organization root ID |
<!-- END_TF_DOCS -->