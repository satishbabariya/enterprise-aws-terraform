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
| <a name="input_enable_shield_advanced"></a> [enable\_shield\_advanced](#input\_enable\_shield\_advanced) | Subscribe to AWS Shield Advanced ($3000/month). Set to true only if your org has committed to the Shield Advanced subscription cost. | `bool` | `false` | no |
| <a name="input_log_destination_arn"></a> [log\_destination\_arn](#input\_log\_destination\_arn) | Kinesis Firehose ARN or CloudWatch Logs ARN for WAF logs. Empty disables logging config (apply logging later via aws\_wafv2\_web\_acl\_logging\_configuration). | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix appended to ACL name. Use to distinguish per-app or per-env ACLs. | `string` | `"baseline"` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_rate_limit_per_5min"></a> [rate\_limit\_per\_5min](#input\_rate\_limit\_per\_5min) | Max requests from a single IP per 5 minutes before blocking. | `number` | `2000` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | REGIONAL (for ALB/API Gateway) or CLOUDFRONT (for CloudFront distributions). | `string` | `"REGIONAL"` | no |
| <a name="input_shield_protected_resources"></a> [shield\_protected\_resources](#input\_shield\_protected\_resources) | ARNs to protect with Shield Advanced (ALB, CloudFront, EIP, Route53 hosted zones, Global Accelerator). Only used when enable\_shield\_advanced = true. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_shield_protection_ids"></a> [shield\_protection\_ids](#output\_shield\_protection\_ids) | Map of resource ARN to Shield protection ID (empty if Shield Advanced disabled) |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | Web ACL ARN - associate to ALB/API Gateway/CloudFront via aws\_wafv2\_web\_acl\_association |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | Web ACL ID |
<!-- END_TF_DOCS -->