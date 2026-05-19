variable "name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS control plane ENIs and nodes."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key for envelope encryption of K8s secrets."
  type        = string
}

variable "endpoint_public_access" {
  description = "Allow public access to the EKS API server endpoint."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach public endpoint when enabled."
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to ship to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 365
}

variable "node_group_instance_types" {
  description = "Instance types for the default managed node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_group_min_size" {
  description = "Minimum nodes."
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum nodes."
  type        = number
  default     = 10
}

variable "node_group_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
