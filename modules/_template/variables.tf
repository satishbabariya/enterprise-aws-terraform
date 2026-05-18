variable "org_name" {
  description = "Short lowercase name for the organization, used in resource naming. Example: acme"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be 2-21 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "region" {
  description = "AWS region for resources. Example: us-east-1"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources."
  type        = map(string)
  default     = {}
}
