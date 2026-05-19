variable "account_id" {
  description = "AWS account ID that owns this key."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "description" {
  description = "Human-readable description of what this key encrypts."
  type        = string
}

variable "key_alias" {
  description = "KMS alias (without 'alias/' prefix). Example: acme-prod-ebs"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Days before key deletion after destroy. Between 7 and 30."
  type        = number
  default     = 30
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "additional_key_admins" {
  description = "List of IAM ARNs that can administer (but not use) this key."
  type        = list(string)
  default     = []
}

variable "additional_key_users" {
  description = "List of IAM ARNs that can use this key for encrypt/decrypt."
  type        = list(string)
  default     = []
}

variable "key_usage" {
  description = "Intended use: ENCRYPT_DECRYPT (symmetric data keys, the default), SIGN_VERIFY (asymmetric signing), KEY_AGREEMENT (ECDH), or GENERATE_VERIFY_MAC (HMAC)."
  type        = string
  default     = "ENCRYPT_DECRYPT"
  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "KEY_AGREEMENT", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be ENCRYPT_DECRYPT, SIGN_VERIFY, KEY_AGREEMENT, or GENERATE_VERIFY_MAC."
  }
}

variable "customer_master_key_spec" {
  description = "Key spec: SYMMETRIC_DEFAULT (256-bit AES, the default), or asymmetric: RSA_2048/3072/4096, ECC_NIST_P256/384/521, ECC_SECG_P256K1, HMAC_224/256/384/512, SM2."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "tags" {
  description = "Tags to apply to the KMS key."
  type        = map(string)
  default     = {}
}
