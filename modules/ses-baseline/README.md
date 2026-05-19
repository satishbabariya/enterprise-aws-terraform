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
| <a name="input_bounce_complaint_topic_arn"></a> [bounce\_complaint\_topic\_arn](#input\_bounce\_complaint\_topic\_arn) | SNS topic ARN to receive bounce and complaint notifications. | `string` | n/a | yes |
| <a name="input_configuration_set_name"></a> [configuration\_set\_name](#input\_configuration\_set\_name) | Name of the SES configuration set. | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to verify for SES sending. | `string` | n/a | yes |
| <a name="input_mail_from_subdomain"></a> [mail\_from\_subdomain](#input\_mail\_from\_subdomain) | Subdomain used as MAIL FROM (e.g., 'mail' creates mail.example.com). Empty disables custom MAIL FROM. | `string` | `"mail"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID for var.domain - used to create DKIM CNAMEs automatically. Empty skips DNS setup (manual). | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_set_arn"></a> [configuration\_set\_arn](#output\_configuration\_set\_arn) | Configuration set ARN |
| <a name="output_dkim_tokens"></a> [dkim\_tokens](#output\_dkim\_tokens) | DKIM tokens (used in CNAME records if Route53 zone wasn't supplied) |
| <a name="output_identity_arn"></a> [identity\_arn](#output\_identity\_arn) | SES email identity ARN - use as source\_arn in apps |
<!-- END_TF_DOCS -->