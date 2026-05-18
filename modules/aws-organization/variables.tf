variable "org_name" {
  description = "Short lowercase org name. Example: acme"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be lowercase alphanumeric + hyphens."
  }
}

variable "organizational_units" {
  description = <<-EOT
    Map of OUs to create. Each entry: { name = string, parent_key = string }.
    Use parent_key = "root" to attach directly to the org root.
    Use the map key of another OU to nest under it.
  EOT
  type = map(object({
    name       = string
    parent_key = string
  }))
  default = {
    security       = { name = "Security", parent_key = "root" }
    infrastructure = { name = "Infrastructure", parent_key = "root" }
    workloads      = { name = "Workloads", parent_key = "root" }
    suspended      = { name = "Suspended", parent_key = "root" }
  }
}

variable "enabled_policy_types" {
  description = "Organization policy types to enable."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
}

variable "tags" {
  description = "Tags to apply to taggable org resources."
  type        = map(string)
  default     = {}
}
