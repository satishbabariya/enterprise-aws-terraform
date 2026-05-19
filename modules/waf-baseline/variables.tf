variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "name_suffix" {
  description = "Suffix appended to ACL name. Use to distinguish per-app or per-env ACLs."
  type        = string
  default     = "baseline"
}

variable "scope" {
  description = "REGIONAL (for ALB/API Gateway) or CLOUDFRONT (for CloudFront distributions)."
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "rate_limit_per_5min" {
  description = "Max requests from a single IP per 5 minutes before blocking."
  type        = number
  default     = 2000
}

variable "log_destination_arn" {
  description = "Kinesis Firehose ARN or CloudWatch Logs ARN for WAF logs. Empty disables logging config (apply logging later via aws_wafv2_web_acl_logging_configuration)."
  type        = string
  default     = ""
}

variable "enable_shield_advanced" {
  description = "Subscribe to AWS Shield Advanced ($3000/month). Set to true only if your org has committed to the Shield Advanced subscription cost."
  type        = bool
  default     = false
}

variable "shield_protected_resources" {
  description = "ARNs to protect with Shield Advanced (ALB, CloudFront, EIP, Route53 hosted zones, Global Accelerator). Only used when enable_shield_advanced = true."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
