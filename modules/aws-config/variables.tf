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
    cis-aws-v1-4   = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml"
    pci-dss-v3-2-1 = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-PCI-DSS.yaml"
    hipaa-security = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml"
    nist-csf       = "s3://aws-service-catalog-reference-architectures-us-east-1/aws-config/conformance-packs/Operational-Best-Practices-for-NIST-CSF.yaml"
  }
}

variable "conformance_pack_delivery_bucket" {
  description = "S3 bucket name for conformance pack delivery. Typically the central log-archive bucket."
  type        = string
  default     = ""
}

variable "managed_rules" {
  description = <<-EOT
    AWS-managed Config rules to enable individually (in addition to conformance packs).
    Use this when a specific rule isn't bundled in a conformance pack you've enabled
    or when you want to enforce a stricter parameter than the pack default.
    Example:
      {
        ROOT_ACCOUNT_MFA_ENABLED = { source_identifier = "ROOT_ACCOUNT_MFA_ENABLED" }
        IAM_PASSWORD_POLICY      = {
          source_identifier = "IAM_PASSWORD_POLICY"
          input_parameters  = { RequireSymbols = "true", MinimumPasswordLength = "14" }
        }
      }
  EOT
  type = map(object({
    source_identifier = string
    input_parameters  = optional(map(string), {})
    description       = optional(string, "")
  }))
  default = {}
}

variable "create_sns_topic" {
  description = "Create an SNS topic that AWS Config publishes change notifications to (for SIEM/Lambda subscribers)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
