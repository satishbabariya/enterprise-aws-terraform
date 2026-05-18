variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "analyzer_type" {
  description = "ACCOUNT or ORGANIZATION."
  type        = string
  default     = "ORGANIZATION"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "Must be ACCOUNT or ORGANIZATION."
  }
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
