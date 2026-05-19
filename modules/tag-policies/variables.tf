variable "tags" {
  description = "Tags for the tag-policy resources themselves."
  type        = map(string)
  default     = {}
}

variable "valid_environments" {
  description = "Allowed values for the Environment tag."
  type        = list(string)
  default     = ["prod", "staging", "dev", "sandbox", "shared", "management"]
}

variable "valid_data_classifications" {
  description = "Allowed values for the DataClass tag."
  type        = list(string)
  default     = ["public", "internal", "confidential", "restricted"]
}

variable "valid_compliance_scopes" {
  description = "Allowed values for the ComplianceScope tag."
  type        = list(string)
  default     = ["none", "cis", "soc2", "pci", "hipaa", "all"]
}

variable "enforced_resource_types" {
  description = "Resource types where tag policy enforcement is applied (prevents non-compliant tagging)."
  type        = list(string)
  default = [
    "ec2:instance",
    "ec2:volume",
    "s3:bucket",
    "rds:db",
    "rds:cluster",
    "dynamodb:table",
    "lambda:function",
    "ecs:cluster",
    "ecs:service",
    "eks:cluster",
    "elasticache:cluster",
  ]
}
