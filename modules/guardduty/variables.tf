variable "delegated_admin_account_id" {
  description = "Account ID of the security account acting as GuardDuty delegated admin."
  type        = string
}

variable "finding_publishing_frequency" {
  description = "How often to publish findings. FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "auto_enable_org_members" {
  description = "Auto-enable GuardDuty for org members: ALL, NEW, or NONE."
  type        = string
  default     = "ALL"
}

variable "enable_runtime_monitoring" {
  description = <<-EOT
    Enable Runtime Monitoring (in-process threat detection for containers/instances).
    Covers ECS Fargate, EC2, and EKS. Mutually exclusive with enable_eks_runtime_monitoring -
    Runtime Monitoring is the newer unified version and supersedes EKS Runtime Monitoring.
  EOT
  type        = bool
  default     = true
}

variable "enable_eks_runtime_monitoring" {
  description = "Legacy EKS Runtime Monitoring. Mutually exclusive with enable_runtime_monitoring; only set this if you have a reason not to use the newer unified Runtime Monitoring."
  type        = bool
  default     = false

  validation {
    condition     = !(var.enable_eks_runtime_monitoring && var.enable_runtime_monitoring)
    error_message = "enable_eks_runtime_monitoring cannot be true when enable_runtime_monitoring is true - the newer Runtime Monitoring already covers EKS."
  }
}

variable "runtime_monitoring_ecs_fargate_addon_management" {
  description = "Let GuardDuty manage the runtime monitoring agent for ECS Fargate tasks."
  type        = bool
  default     = true
}

variable "runtime_monitoring_ec2_agent_management" {
  description = "Let GuardDuty manage the runtime monitoring agent installation on EC2."
  type        = bool
  default     = true
}

variable "runtime_monitoring_eks_addon_management" {
  description = "Let GuardDuty manage the runtime monitoring agent installation on EKS."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
