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
| <a name="input_auto_enable_new_accounts"></a> [auto\_enable\_new\_accounts](#input\_auto\_enable\_new\_accounts) | Auto-enable Security Hub for new org accounts. | `bool` | `true` | no |
| <a name="input_enable_cis_standard"></a> [enable\_cis\_standard](#input\_enable\_cis\_standard) | Enable CIS AWS Foundations Benchmark v3.0 | `bool` | `true` | no |
| <a name="input_enable_nist_standard"></a> [enable\_nist\_standard](#input\_enable\_nist\_standard) | Enable NIST SP 800-53 Rev 5 | `bool` | `true` | no |
| <a name="input_enable_pci_standard"></a> [enable\_pci\_standard](#input\_enable\_pci\_standard) | Enable PCI-DSS v3.2.1 | `bool` | `true` | no |
| <a name="input_finding_aggregator_regions"></a> [finding\_aggregator\_regions](#input\_finding\_aggregator\_regions) | List of regions whose findings should aggregate into the current region.<br>Set to ["*"] to aggregate ALL regions where Security Hub is enabled.<br>Empty list disables the finding aggregator. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_product_subscriptions"></a> [product\_subscriptions](#input\_product\_subscriptions) | AWS-native security products whose findings should be ingested into Security Hub. | <pre>object({<br>    guardduty        = optional(bool, true)<br>    inspector        = optional(bool, true)<br>    macie            = optional(bool, true)<br>    config           = optional(bool, true)<br>    access_analyzer  = optional(bool, true)<br>    firewall_manager = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_suppressed_controls"></a> [suppressed\_controls](#input\_suppressed\_controls) | Map of Security Hub control IDs to auto-suppress (creates aws\_securityhub\_automation\_rule).<br>Use this for controls the org has consciously accepted as N/A or compensated for elsewhere.<br>Example:<br>  {<br>    "Lambda.1" = {<br>      rule\_order      = 1<br>      disabled\_reason = "Public Lambda URLs are explicitly approved for the webhook receiver"<br>    }<br>  } | <pre>map(object({<br>    rule_order      = number<br>    disabled_reason = string<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_finding_aggregator_arn"></a> [finding\_aggregator\_arn](#output\_finding\_aggregator\_arn) | Finding aggregator ARN (empty if disabled) |
| <a name="output_hub_arn"></a> [hub\_arn](#output\_hub\_arn) | Security Hub account resource ID |
| <a name="output_product_subscription_arns"></a> [product\_subscription\_arns](#output\_product\_subscription\_arns) | Map of product name to subscription ARN |
<!-- END_TF_DOCS -->