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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_conformance_pack_delivery_bucket"></a> [conformance\_pack\_delivery\_bucket](#input\_conformance\_pack\_delivery\_bucket) | S3 bucket name for conformance pack delivery. Typically the central log-archive bucket. | `string` | `""` | no |
| <a name="input_conformance_packs"></a> [conformance\_packs](#input\_conformance\_packs) | Conformance packs to deploy. Map of pack name to AWS-published template S3 URI.<br>The empty default deploys nothing - set to enable. See docs/compliance-matrix.md<br>for the canonical URIs for CIS, PCI-DSS, HIPAA, NIST. | `map(string)` | <pre>{<br>  "cis-aws-v1-4": "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml",<br>  "hipaa-security": "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml",<br>  "nist-csf": "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-NIST-CSF.yaml",<br>  "pci-dss-v3-2-1": "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-PCI-DSS.yaml"<br>}</pre> | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Create an SNS topic that AWS Config publishes change notifications to (for SIEM/Lambda subscribers). | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for Config snapshot encryption. | `string` | n/a | yes |
| <a name="input_log_archive_bucket_name"></a> [log\_archive\_bucket\_name](#input\_log\_archive\_bucket\_name) | Centralized log archive bucket name. | `string` | n/a | yes |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | AWS-managed Config rules to enable individually (in addition to conformance packs).<br>Use this when a specific rule isn't bundled in a conformance pack you've enabled<br>or when you want to enforce a stricter parameter than the pack default.<br>Example:<br>  {<br>    ROOT\_ACCOUNT\_MFA\_ENABLED = { source\_identifier = "ROOT\_ACCOUNT\_MFA\_ENABLED" }<br>    IAM\_PASSWORD\_POLICY      = {<br>      source\_identifier = "IAM\_PASSWORD\_POLICY"<br>      input\_parameters  = { RequireSymbols = "true", MinimumPasswordLength = "14" }<br>    }<br>  } | <pre>map(object({<br>    source_identifier = string<br>    input_parameters  = optional(map(string), {})<br>    description       = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_org_aggregator_account_id"></a> [org\_aggregator\_account\_id](#input\_org\_aggregator\_account\_id) | Security account ID that aggregates Config data. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aggregator_arn"></a> [aggregator\_arn](#output\_aggregator\_arn) | Config aggregator ARN |
| <a name="output_conformance_pack_arns"></a> [conformance\_pack\_arns](#output\_conformance\_pack\_arns) | Map of conformance pack key to ARN |
| <a name="output_delivery_channel_id"></a> [delivery\_channel\_id](#output\_delivery\_channel\_id) | Config delivery channel ID |
| <a name="output_managed_rule_arns"></a> [managed\_rule\_arns](#output\_managed\_rule\_arns) | Map of managed Config rule name to ARN |
| <a name="output_recorder_id"></a> [recorder\_id](#output\_recorder\_id) | Config recorder ID |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | Config SNS notification topic ARN (empty if not created) |
<!-- END_TF_DOCS -->