variable "domain_name" {
  description = "Private hosted zone name. Example: prod.acme.internal"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the private hosted zone."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
