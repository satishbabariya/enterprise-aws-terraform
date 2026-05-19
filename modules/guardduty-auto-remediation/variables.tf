variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "critical_alert_topic_arn" {
  description = "SNS topic ARN for critical-severity GuardDuty findings."
  type        = string
}

variable "high_alert_topic_arn" {
  description = "SNS topic ARN for high-severity findings."
  type        = string
}

variable "auto_quarantine_findings" {
  description = "GuardDuty finding types that trigger automatic resource quarantine (block-all SG attached to compromised EC2)."
  type        = list(string)
  default = [
    "Backdoor:EC2/C&CActivity.B!DNS",
    "Backdoor:EC2/Spambot",
    "CryptoCurrency:EC2/BitcoinTool.B!DNS",
    "Trojan:EC2/BlackholeTraffic",
    "Trojan:EC2/DriveBySourceTraffic!DNS",
    "Trojan:EC2/DropPoint!DNS",
    "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom",
    "UnauthorizedAccess:EC2/MetadataDNSRebind",
  ]
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
