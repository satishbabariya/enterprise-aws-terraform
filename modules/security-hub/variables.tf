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

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
