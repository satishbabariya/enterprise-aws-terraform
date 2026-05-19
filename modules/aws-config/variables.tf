variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Centralized log archive bucket name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for Config snapshot encryption."
  type        = string
}

variable "org_aggregator_account_id" {
  description = "Security account ID that aggregates Config data."
  type        = string
}

variable "conformance_packs" {
  description = <<-EOT
    Conformance packs to deploy. Map of pack name to AWS-published template S3 URI.
    The empty default deploys nothing - set to enable. See docs/compliance-matrix.md
    for the canonical URIs for CIS, PCI-DSS, HIPAA, NIST.
  EOT
  type        = map(string)
  default = {
    cis-aws-v1-4         = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml"
    pci-dss-v3-2-1       = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-PCI-DSS.yaml"
    hipaa-security       = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml"
    nist-csf             = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-NIST-CSF.yaml"
  }
}

variable "conformance_pack_delivery_bucket" {
  description = "S3 bucket name for conformance pack delivery. Typically the central log-archive bucket."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
