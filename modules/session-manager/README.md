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
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Short lowercase account name. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_session_idle_timeout_minutes"></a> [session\_idle\_timeout\_minutes](#input\_session\_idle\_timeout\_minutes) | Idle timeout for SSM sessions in minutes. | `number` | `15` | no |
| <a name="input_session_log_bucket_arn"></a> [session\_log\_bucket\_arn](#input\_session\_log\_bucket\_arn) | S3 bucket ARN where session transcripts are stored (typically log-archive). | `string` | n/a | yes |
| <a name="input_session_log_kms_key_arn"></a> [session\_log\_kms\_key\_arn](#input\_session\_log\_kms\_key\_arn) | KMS key ARN for encrypting session transcripts. | `string` | n/a | yes |
| <a name="input_session_max_duration_minutes"></a> [session\_max\_duration\_minutes](#input\_session\_max\_duration\_minutes) | Max session duration in minutes. | `number` | `60` | no |
| <a name="input_shell_profile_linux"></a> [shell\_profile\_linux](#input\_shell\_profile\_linux) | Optional shell profile applied to Linux sessions (commands run at session start). | `string` | `"export PROMPT_COMMAND='history -a' && export HISTFILE=/tmp/.bash_history"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | Instance profile ARN |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Attach this instance profile to EC2 instances to enable Session Manager |
| <a name="output_instance_role_arn"></a> [instance\_role\_arn](#output\_instance\_role\_arn) | Instance role ARN (use this if you need to attach additional policies) |
| <a name="output_session_log_group_name"></a> [session\_log\_group\_name](#output\_session\_log\_group\_name) | CloudWatch log group receiving session streams |
<!-- END_TF_DOCS -->