variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name."
  type        = string
}

variable "session_log_bucket_arn" {
  description = "S3 bucket ARN where session transcripts are stored (typically log-archive)."
  type        = string
}

variable "session_log_kms_key_arn" {
  description = "KMS key ARN for encrypting session transcripts."
  type        = string
}

variable "session_idle_timeout_minutes" {
  description = "Idle timeout for SSM sessions in minutes."
  type        = number
  default     = 15
}

variable "session_max_duration_minutes" {
  description = "Max session duration in minutes."
  type        = number
  default     = 60
}

variable "shell_profile_linux" {
  description = "Optional shell profile applied to Linux sessions (commands run at session start)."
  type        = string
  default     = "export PROMPT_COMMAND='history -a' && export HISTFILE=/tmp/.bash_history"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
