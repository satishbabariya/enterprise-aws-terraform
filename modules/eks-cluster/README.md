<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_oidc_provider"></a> [create\_oidc\_provider](#input\_create\_oidc\_provider) | Create an IAM OIDC identity provider for the cluster. Required for IRSA (IAM Roles for Service Accounts). | `bool` | `true` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | Control plane log types to ship to CloudWatch. | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Allow public access to the EKS API server endpoint. | `bool` | `false` | no |
| <a name="input_endpoint_public_access_cidrs"></a> [endpoint\_public\_access\_cidrs](#input\_endpoint\_public\_access\_cidrs) | CIDRs allowed to reach public endpoint when enabled. | `list(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key for envelope encryption of K8s secrets. | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | EKS Kubernetes version. | `string` | `"1.30"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention. | `number` | `365` | no |
| <a name="input_managed_addons"></a> [managed\_addons](#input\_managed\_addons) | AWS-managed EKS addons. Each entry can override version, configuration JSON,<br>and an explicit IRSA role ARN. Default includes the 4 core addons every cluster needs.<br>Set enabled=false on any entry to skip that addon. | <pre>map(object({<br>    enabled                     = optional(bool, true)<br>    addon_version               = optional(string, null)<br>    configuration_values        = optional(string, null)<br>    service_account_role_arn    = optional(string, null)<br>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br>  }))</pre> | <pre>{<br>  "aws-ebs-csi-driver": {},<br>  "coredns": {},<br>  "kube-proxy": {},<br>  "vpc-cni": {}<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | EKS cluster name. | `string` | n/a | yes |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | Desired node count. | `number` | `3` | no |
| <a name="input_node_group_instance_types"></a> [node\_group\_instance\_types](#input\_node\_group\_instance\_types) | Instance types for the default managed node group. | `list(string)` | <pre>[<br>  "m6i.large"<br>]</pre> | no |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | Maximum nodes. | `number` | `10` | no |
| <a name="input_node_group_min_size"></a> [node\_group\_min\_size](#input\_node\_group\_min\_size) | Minimum nodes. | `number` | `2` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets for EKS control plane ENIs and nodes. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_addon_arns"></a> [addon\_arns](#output\_addon\_arns) | Map of addon name to ARN |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | EKS cluster ARN |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 cluster CA cert |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Kubernetes API server endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_irsa_role_arns"></a> [irsa\_role\_arns](#output\_irsa\_role\_arns) | Map of addon name to auto-created IRSA role ARN |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn) | Node group IAM role ARN |
| <a name="output_oidc_issuer_hostname"></a> [oidc\_issuer\_hostname](#output\_oidc\_issuer\_hostname) | OIDC issuer URL without https:// - use to build sub conditions like system:serviceaccount:<ns>:<sa> |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL - use for IRSA setup |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | IAM OIDC provider ARN - use as Federated principal in IRSA trust policies |
<!-- END_TF_DOCS -->