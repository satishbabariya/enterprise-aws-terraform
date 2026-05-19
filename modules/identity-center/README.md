<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | SSO account assignments. principal\_type = "GROUP" (recommended) or "USER".<br>For GROUP assignments, set principal\_id to a key from var.groups - the module<br>resolves it to the created group's ID. For USER, pass the identity store user ID directly. | <pre>list(object({<br>    account_id          = string<br>    permission_set_name = string<br>    principal_type      = string<br>    principal_id        = string<br>  }))</pre> | `[]` | no |
| <a name="input_custom_permission_sets"></a> [custom\_permission\_sets](#input\_custom\_permission\_sets) | Persona-specific permission sets. Each set can combine AWS-managed policy<br>ARNs with an inline policy (JSON). Use this for tight least-privilege roles<br>like WorkloadDeveloperProd, BreakGlassAdmin, ExternalContractor, etc. | <pre>map(object({<br>    description         = string<br>    session_duration    = string<br>    managed_policy_arns = optional(list(string), [])<br>    inline_policy_json  = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | SSO groups to create in the Identity Store. Map of group name to display description. | `map(string)` | `{}` | no |
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | Identity store ID. Get from: aws sso-admin list-instances | `string` | n/a | yes |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | Permission sets backed by AWS-managed policies. Use custom\_permission\_sets for inline-policy or persona-specific sets. | <pre>map(object({<br>    description         = string<br>    session_duration    = string<br>    managed_policy_arns = list(string)<br>  }))</pre> | <pre>{<br>  "AdministratorAccess": {<br>    "description": "Full administrative access",<br>    "managed_policy_arns": [<br>      "arn:aws:iam::aws:policy/AdministratorAccess"<br>    ],<br>    "session_duration": "PT4H"<br>  },<br>  "BillingReadOnly": {<br>    "description": "Read-only access to billing and cost data",<br>    "managed_policy_arns": [<br>      "arn:aws:iam::aws:policy/job-function/Billing"<br>    ],<br>    "session_duration": "PT8H"<br>  },<br>  "PowerUserAccess": {<br>    "description": "Power user without IAM/Org changes",<br>    "managed_policy_arns": [<br>      "arn:aws:iam::aws:policy/PowerUserAccess"<br>    ],<br>    "session_duration": "PT8H"<br>  },<br>  "ReadOnlyAccess": {<br>    "description": "Read-only access across all services",<br>    "managed_policy_arns": [<br>      "arn:aws:iam::aws:policy/ReadOnlyAccess"<br>    ],<br>    "session_duration": "PT8H"<br>  },<br>  "SecurityAudit": {<br>    "description": "Security audit and compliance review access",<br>    "managed_policy_arns": [<br>      "arn:aws:iam::aws:policy/SecurityAudit"<br>    ],<br>    "session_duration": "PT8H"<br>  }<br>}</pre> | no |
| <a name="input_sso_instance_arn"></a> [sso\_instance\_arn](#input\_sso\_instance\_arn) | ARN of the SSO instance. Get from: aws sso-admin list-instances | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_permission_set_arns"></a> [custom\_permission\_set\_arns](#output\_custom\_permission\_set\_arns) | Map of custom (inline policy) permission set name to ARN |
| <a name="output_group_ids"></a> [group\_ids](#output\_group\_ids) | Map of group name to identity store group ID |
| <a name="output_permission_set_arns"></a> [permission\_set\_arns](#output\_permission\_set\_arns) | Map of managed-policy-backed permission set name to ARN |
<!-- END_TF_DOCS -->