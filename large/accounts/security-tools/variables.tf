variable "org_name" {
  type        = string
  description = "Org name."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region."
}

variable "repo_url" {
  type        = string
  description = "GitHub repo URL."
}

variable "account_id" {
  type        = string
  description = "Security-tools account ID."
}

variable "github_org" {
  type        = string
  description = "GitHub org name."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name."
}
