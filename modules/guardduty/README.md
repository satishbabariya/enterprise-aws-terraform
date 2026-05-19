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
| <a name="input_auto_enable_org_members"></a> [auto\_enable\_org\_members](#input\_auto\_enable\_org\_members) | Auto-enable GuardDuty for org members: ALL, NEW, or NONE. | `string` | `"ALL"` | no |
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | Account ID of the security account acting as GuardDuty delegated admin. | `string` | n/a | yes |
| <a name="input_enable_eks_runtime_monitoring"></a> [enable\_eks\_runtime\_monitoring](#input\_enable\_eks\_runtime\_monitoring) | Legacy EKS Runtime Monitoring. Mutually exclusive with enable\_runtime\_monitoring; only set this if you have a reason not to use the newer unified Runtime Monitoring. | `bool` | `false` | no |
| <a name="input_enable_runtime_monitoring"></a> [enable\_runtime\_monitoring](#input\_enable\_runtime\_monitoring) | Enable Runtime Monitoring (in-process threat detection for containers/instances).<br>Covers ECS Fargate, EC2, and EKS. Mutually exclusive with enable\_eks\_runtime\_monitoring -<br>Runtime Monitoring is the newer unified version and supersedes EKS Runtime Monitoring. | `bool` | `true` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | How often to publish findings. FIFTEEN\_MINUTES, ONE\_HOUR, or SIX\_HOURS. | `string` | `"SIX_HOURS"` | no |
| <a name="input_runtime_monitoring_ec2_agent_management"></a> [runtime\_monitoring\_ec2\_agent\_management](#input\_runtime\_monitoring\_ec2\_agent\_management) | Let GuardDuty manage the runtime monitoring agent installation on EC2. | `bool` | `true` | no |
| <a name="input_runtime_monitoring_ecs_fargate_addon_management"></a> [runtime\_monitoring\_ecs\_fargate\_addon\_management](#input\_runtime\_monitoring\_ecs\_fargate\_addon\_management) | Let GuardDuty manage the runtime monitoring agent for ECS Fargate tasks. | `bool` | `true` | no |
| <a name="input_runtime_monitoring_eks_addon_management"></a> [runtime\_monitoring\_eks\_addon\_management](#input\_runtime\_monitoring\_eks\_addon\_management) | Let GuardDuty manage the runtime monitoring agent installation on EKS. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_detector_arn"></a> [detector\_arn](#output\_detector\_arn) | GuardDuty detector ARN |
| <a name="output_detector_id"></a> [detector\_id](#output\_detector\_id) | GuardDuty detector ID |
<!-- END_TF_DOCS -->