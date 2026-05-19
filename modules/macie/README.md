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
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | Security account ID that becomes Macie delegated admin. | `string` | n/a | yes |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | How often to publish findings. | `string` | `"SIX_HOURS"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Macie account resource ID |
<!-- END_TF_DOCS -->