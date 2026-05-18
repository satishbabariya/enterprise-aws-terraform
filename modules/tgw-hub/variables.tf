variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "amazon_side_asn" {
  description = "BGP ASN for the TGW. Use a private ASN."
  type        = number
  default     = 64512
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to route through the TGW."
  type        = list(string)
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
