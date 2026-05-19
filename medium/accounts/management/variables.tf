variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL."
  type        = string
}

variable "github_org" {
  description = "GitHub organization name."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "management_account_id" {
  description = "Management account ID."
  type        = string
}

variable "sso_instance_arn" {
  description = "From: aws sso-admin list-instances"
  type        = string
}

variable "identity_store_id" {
  description = "From: aws sso-admin list-instances"
  type        = string
}

variable "allowed_regions" {
  description = "Regions allowed by the deny-regions SCP."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}
