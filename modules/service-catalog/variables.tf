variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "portfolio_provider" {
  description = "Provider display name (typically the platform team)."
  type        = string
  default     = "Platform Team"
}

variable "shared_with_principal_arns" {
  description = "IAM principal ARNs allowed to launch products (typically SSO permission set ARNs for developer groups)."
  type        = list(string)
  default     = []
}

variable "products" {
  description = <<-EOT
    Map of approved products. Each product references a CloudFormation template
    (S3 URL) and version. Add products for VPCs, ECS services, RDS instances,
    etc. that developers can self-service through the AWS console.
  EOT
  type = map(object({
    description         = string
    owner               = string
    template_url        = string
    version_description = optional(string, "Initial version")
    distributor         = optional(string, "")
    support_email       = optional(string, "")
    support_url         = optional(string, "")
  }))
  default = {}
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
