variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name."
  type        = string
}

variable "tgw_id" {
  description = "Transit Gateway ID from tgw-hub outputs."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs to attach to the TGW."
  type        = list(string)
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
