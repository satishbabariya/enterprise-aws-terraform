variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "max_secret_age_days" {
  description = "Config rule threshold - alert if a secret has not been rotated in this many days."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
