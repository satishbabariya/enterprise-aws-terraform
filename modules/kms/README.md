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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID that owns this key. | `string` | n/a | yes |
| <a name="input_additional_key_admins"></a> [additional\_key\_admins](#input\_additional\_key\_admins) | List of IAM ARNs that can administer (but not use) this key. | `list(string)` | `[]` | no |
| <a name="input_additional_key_users"></a> [additional\_key\_users](#input\_additional\_key\_users) | List of IAM ARNs that can use this key for encrypt/decrypt. | `list(string)` | `[]` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | Key spec: SYMMETRIC\_DEFAULT (256-bit AES, the default), or asymmetric: RSA\_2048/3072/4096, ECC\_NIST\_P256/384/521, ECC\_SECG\_P256K1, HMAC\_224/256/384/512, SM2. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Days before key deletion after destroy. Between 7 and 30. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of what this key encrypts. | `string` | n/a | yes |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | KMS alias (without 'alias/' prefix). Example: acme-prod-ebs | `string` | n/a | yes |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Intended use: ENCRYPT\_DECRYPT (symmetric data keys, the default), SIGN\_VERIFY (asymmetric signing), KEY\_AGREEMENT (ECDH), or GENERATE\_VERIFY\_MAC (HMAC). | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the KMS key. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | KMS alias ARN |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | KMS alias name (including alias/ prefix) |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | KMS key ARN |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | KMS key ID |
<!-- END_TF_DOCS -->