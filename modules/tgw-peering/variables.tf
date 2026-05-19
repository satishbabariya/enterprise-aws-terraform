variable "primary_tgw_id" {
  description = "TGW ID in the primary region (provider aws.primary)."
  type        = string
}

variable "secondary_tgw_id" {
  description = "TGW ID in the secondary region (provider aws.secondary)."
  type        = string
}

variable "secondary_region" {
  description = "AWS region for the secondary TGW."
  type        = string
}

variable "secondary_account_id" {
  description = "Account ID owning the secondary TGW. If same as primary, leave empty."
  type        = string
  default     = ""
}

variable "name" {
  description = "Name tag for the peering attachment."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
