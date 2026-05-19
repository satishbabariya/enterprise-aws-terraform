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
| <a name="input_experiment_target_tag_key"></a> [experiment\_target\_tag\_key](#input\_experiment\_target\_tag\_key) | Resources tagged with this key are eligible for chaos experiments. | `string` | `"ChaosEligible"` | no |
| <a name="input_experiment_target_tag_value"></a> [experiment\_target\_tag\_value](#input\_experiment\_target\_tag\_value) | Tag value matching for chaos eligibility. | `string` | `"true"` | no |
| <a name="input_log_group_arn"></a> [log\_group\_arn](#input\_log\_group\_arn) | CloudWatch log group for FIS experiment logs. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_stop_condition_alarm_arns"></a> [stop\_condition\_alarm\_arns](#input\_stop\_condition\_alarm\_arns) | CloudWatch alarm ARNs that will halt running experiments if breached. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_experiment_template_ids"></a> [experiment\_template\_ids](#output\_experiment\_template\_ids) | Map of experiment name to FIS template ID |
| <a name="output_fis_role_arn"></a> [fis\_role\_arn](#output\_fis\_role\_arn) | FIS service role ARN |
<!-- END_TF_DOCS -->