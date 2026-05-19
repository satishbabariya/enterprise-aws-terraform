variable "name" {
  description = "DynamoDB table name."
  type        = string
}

variable "hash_key" {
  description = "Partition key name."
  type        = string
}

variable "hash_key_type" {
  description = "S/N/B"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Sort key name. Empty for none."
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "S/N/B"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "kms_key_arn" {
  description = "KMS key for SSE."
  type        = string
}

variable "ttl_attribute" {
  description = "TTL attribute name. Empty disables TTL."
  type        = string
  default     = ""
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
