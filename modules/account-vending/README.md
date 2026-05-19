<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | Map of accounts to vend. Each entry:<br>  name              - Account display name (e.g., "Acme - Team Foo - Prod")<br>  email             - Unique email for the account root<br>  ou\_key            - Key from aws\_organization module's organizational\_unit\_ids output (e.g., "workloads")<br>  ou\_id             - Organization OU ID to place the account in<br>  role\_name         - Cross-account role name (default: OrganizationAccountAccessRole)<br>  iam\_user\_access   - "ALLOW" or "DENY" - whether IAM users can access billing console<br>  close\_on\_destroy  - If true, terraform destroy initiates account close (90-day suspension) | <pre>map(object({<br>    email            = string<br>    ou_id            = string<br>    role_name        = optional(string, "OrganizationAccountAccessRole")<br>    iam_user_access  = optional(string, "DENY")<br>    close_on_destroy = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all vended accounts. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_arns"></a> [account\_arns](#output\_account\_arns) | Map of account name to account ARN |
| <a name="output_account_ids"></a> [account\_ids](#output\_account\_ids) | Map of account name to 12-digit account ID |
<!-- END_TF_DOCS -->