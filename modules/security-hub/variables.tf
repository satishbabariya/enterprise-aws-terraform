variable "enable_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark v3.0"
  type        = bool
  default     = true
}

variable "enable_pci_standard" {
  description = "Enable PCI-DSS v3.2.1"
  type        = bool
  default     = true
}

variable "enable_nist_standard" {
  description = "Enable NIST SP 800-53 Rev 5"
  type        = bool
  default     = true
}

variable "auto_enable_new_accounts" {
  description = "Auto-enable Security Hub for new org accounts."
  type        = bool
  default     = true
}

variable "finding_aggregator_regions" {
  description = <<-EOT
    List of regions whose findings should aggregate into the current region.
    Set to ["*"] to aggregate ALL regions where Security Hub is enabled.
    Empty list disables the finding aggregator.
  EOT
  type        = list(string)
  default     = ["*"]
}

variable "product_subscriptions" {
  description = "AWS-native security products whose findings should be ingested into Security Hub."
  type = object({
    guardduty        = optional(bool, true)
    inspector        = optional(bool, true)
    macie            = optional(bool, true)
    config           = optional(bool, true)
    access_analyzer  = optional(bool, true)
    firewall_manager = optional(bool, false)
  })
  default = {}
}

variable "suppressed_controls" {
  description = <<-EOT
    Map of Security Hub control IDs to auto-suppress (creates aws_securityhub_automation_rule).
    Use this for controls the org has consciously accepted as N/A or compensated for elsewhere.
    Example:
      {
        "Lambda.1" = {
          rule_order      = 1
          disabled_reason = "Public Lambda URLs are explicitly approved for the webhook receiver"
        }
      }
  EOT
  type = map(object({
    rule_order      = number
    disabled_reason = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
