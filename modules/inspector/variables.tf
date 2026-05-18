variable "delegated_admin_account_id" {
  description = "Security account ID that becomes Inspector delegated admin."
  type        = string
}

variable "auto_enable" {
  description = "Per-resource-type auto-enable for new org members."
  type = object({
    ec2         = bool
    ecr         = bool
    lambda      = bool
    lambda_code = bool
  })
  default = {
    ec2         = true
    ecr         = true
    lambda      = true
    lambda_code = true
  }
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
