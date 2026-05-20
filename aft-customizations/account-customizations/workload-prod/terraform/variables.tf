variable "aft_request_metadata_account_name" {
  type        = string
  description = "AFT-injected: account name"
}

variable "workload_cidrs" {
  type        = map(string)
  description = "Map of account-name to VPC CIDR. Pulled from your address space tracking."
  default     = {}
}
