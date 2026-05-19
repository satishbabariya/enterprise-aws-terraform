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
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | Security account ID acting as Audit Manager delegated admin. | `string` | n/a | yes |
| <a name="input_evidence_bucket_name"></a> [evidence\_bucket\_name](#input\_evidence\_bucket\_name) | S3 bucket where Audit Manager evidence is delivered (typically log-archive). | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for evidence encryption. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#output\_delegated\_admin\_account\_id) | Audit Manager delegated admin account |
<!-- END_TF_DOCS -->