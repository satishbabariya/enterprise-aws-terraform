variable "allowed_regions" {
  description = "List of AWS regions to allow. All other regions are denied."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "tags" {
  description = "Tags for SCP resources."
  type        = map(string)
  default     = {}
}
