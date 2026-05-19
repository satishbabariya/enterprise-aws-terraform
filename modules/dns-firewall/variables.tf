variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "vpc_ids" {
  description = "VPC IDs to associate the DNS firewall rule group with."
  type        = list(string)
}

variable "blocked_domains" {
  description = "Domains to block at the DNS resolver. Wildcards via *.example.com."
  type        = list(string)
  default     = []
}

variable "allowed_domains" {
  description = "Domains explicitly allowed - takes precedence over blocked_domains and managed lists."
  type        = list(string)
  default     = []
}

variable "managed_domain_list_ids" {
  description = <<-EOT
    Map of AWS-managed domain list IDs to attach. Look up region-specific IDs with:
      aws route53resolver list-firewall-domain-lists
    Example:
      {
        malware = "rslvr-fdl-2c46f2eced3c4abf"
        botnet  = "rslvr-fdl-1bdb8b1ce4654644"
      }
  EOT
  type        = map(string)
  default     = {}
}

variable "block_action" {
  description = "BLOCK, ALERT, or BLOCK_AND_REPLY"
  type        = string
  default     = "BLOCK"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
