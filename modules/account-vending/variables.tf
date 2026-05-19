variable "accounts" {
  description = <<-EOT
    Map of accounts to vend. Each entry:
      name              - Account display name (e.g., "Acme - Team Foo - Prod")
      email             - Unique email for the account root
      ou_key            - Key from aws_organization module's organizational_unit_ids output (e.g., "workloads")
      ou_id             - Organization OU ID to place the account in
      role_name         - Cross-account role name (default: OrganizationAccountAccessRole)
      iam_user_access   - "ALLOW" or "DENY" - whether IAM users can access billing console
      close_on_destroy  - If true, terraform destroy initiates account close (90-day suspension)
  EOT
  type = map(object({
    email            = string
    ou_id            = string
    role_name        = optional(string, "OrganizationAccountAccessRole")
    iam_user_access  = optional(string, "DENY")
    close_on_destroy = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all vended accounts."
  type        = map(string)
  default     = {}
}
