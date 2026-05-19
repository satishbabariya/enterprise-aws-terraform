variable "account_id" {
  description = "AWS account ID owning the key (same on both regions for a multi-region key)."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "description" {
  description = "Key description."
  type        = string
}

variable "key_alias" {
  description = "KMS alias (without 'alias/' prefix). Same alias is created in both regions."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Pending-deletion window in days (7-30)."
  type        = number
  default     = 30
}

variable "additional_key_admins" {
  description = "IAM ARNs allowed to administer the key."
  type        = list(string)
  default     = []
}

variable "additional_key_users" {
  description = "IAM ARNs allowed to use the key for encrypt/decrypt."
  type        = list(string)
  default     = []
}

variable "service_principals" {
  description = "AWS service principals (e.g. cloudtrail.amazonaws.com) granted use of the key. Restricted via aws:SourceArn in the caller."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
