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

variable "org_id" {
  description = "AWS Organizations organization ID."
  type        = string
}

variable "shared_services_account_id" {
  description = "Shared services account ID."
  type        = string
}

variable "github_org" {
  description = "GitHub org name."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name."
  type        = string
}
