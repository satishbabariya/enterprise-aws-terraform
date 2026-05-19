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
| <a name="input_allowed_regions"></a> [allowed\_regions](#input\_allowed\_regions) | List of AWS regions to allow. All other regions are denied. | `list(string)` | <pre>[<br>  "us-east-1",<br>  "us-west-2"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for SCP resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | Map of SCP name to policy ID |
<!-- END_TF_DOCS -->