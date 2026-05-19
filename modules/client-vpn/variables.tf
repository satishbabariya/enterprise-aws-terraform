variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Client VPN endpoints are created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (one per AZ) for the Client VPN ENIs."
  type        = list(string)
}

variable "client_cidr_block" {
  description = "CIDR block for VPN client IPs (must be /22 or larger, not overlapping VPC)."
  type        = string
  default     = "10.255.0.0/22"
}

variable "server_certificate_arn" {
  description = "ACM certificate ARN for the VPN server. Issue via AWS Private CA or import."
  type        = string
}

variable "saml_provider_arn" {
  description = "IAM SAML provider ARN for federated user authentication. Empty disables SAML auth."
  type        = string
  default     = ""
}

variable "self_service_saml_provider_arn" {
  description = "Optional separate SAML provider for the self-service portal."
  type        = string
  default     = ""
}

variable "mutual_auth_root_ca_arn" {
  description = "Root CA ACM ARN for certificate-based mutual auth. Set when SAML is not used."
  type        = string
  default     = ""
}

variable "split_tunnel" {
  description = "Split tunneling - only VPC-bound traffic uses the VPN. Best for performance + privacy."
  type        = bool
  default     = true
}

variable "session_timeout_hours" {
  description = "Maximum session duration: 8, 10, 12, or 24."
  type        = number
  default     = 12
}

variable "allowed_routes" {
  description = "Destination CIDRs reachable through the VPN. Add VPC CIDR + any peered networks."
  type        = list(string)
}

variable "authorize_groups" {
  description = "SAML group SIDs allowed to connect. Empty allows all authenticated users."
  type        = list(string)
  default     = []
}

variable "log_group_name" {
  description = "CloudWatch log group for connection logs."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
