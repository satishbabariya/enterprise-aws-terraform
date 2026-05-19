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

variable "additional_attributes" {
  description = "Additional attributes referenced by GSIs/LSIs. Each: { name, type (S/N/B) }. Only index-key attributes need to be declared."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = <<-EOT
    Global Secondary Indexes. Each entry:
      name, hash_key, range_key (optional), projection_type (ALL/KEYS_ONLY/INCLUDE),
      non_key_attributes (when projection_type = INCLUDE), read/write_capacity (PROVISIONED only).
  EOT
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Local Secondary Indexes. Must be defined at table creation; cannot be added later."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "global_table_regions" {
  description = "Other AWS regions to replicate the table to via Global Tables v2. Empty disables. Replicas must use the same KMS key alias (caller responsibility)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
