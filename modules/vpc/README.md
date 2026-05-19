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
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Short lowercase account name. Example: prod | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of 3 AZ names. | `list(string)` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | VPC CIDR. Example: 10.0.0.0/16 | `string` | n/a | yes |
| <a name="input_eks_cluster_names"></a> [eks\_cluster\_names](#input\_eks\_cluster\_names) | EKS cluster names that should additionally tag subnets with kubernetes.io/cluster/<name> = shared. Required when sharing a VPC across multiple clusters. | `list(string)` | `[]` | no |
| <a name="input_eks_subnet_tags_enabled"></a> [eks\_subnet\_tags\_enabled](#input\_eks\_subnet\_tags\_enabled) | Add kubernetes.io/role/elb (public) and kubernetes.io/role/internal-elb (private)<br>tags so the AWS Load Balancer Controller can auto-discover subnets. Required<br>if this VPC hosts EKS workloads. Safe to leave on - costs nothing if no EKS. | `bool` | `true` | no |
| <a name="input_enable_gateway_endpoints"></a> [enable\_gateway\_endpoints](#input\_enable\_gateway\_endpoints) | Create Gateway endpoints (S3, DynamoDB). Free; no NAT bypass cost. | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Provision NAT gateways for private subnets. | `bool` | `true` | no |
| <a name="input_flow_log_kms_key_arn"></a> [flow\_log\_kms\_key\_arn](#input\_flow\_log\_kms\_key\_arn) | KMS key ARN for VPC flow log encryption. | `string` | n/a | yes |
| <a name="input_interface_endpoint_services"></a> [interface\_endpoint\_services](#input\_interface\_endpoint\_services) | Interface endpoint service short names to create (without 'com.amazonaws.<region>.' prefix).<br>Each interface endpoint costs ~$7.20/month/AZ plus data charges, but avoids NAT bandwidth.<br>Common picks: ssm, ssmmessages, ec2messages, ec2, kms, logs, secretsmanager,<br>monitoring, sts, ecr.api, ecr.dkr. | `list(string)` | <pre>[<br>  "ssm",<br>  "ssmmessages",<br>  "ec2messages",<br>  "kms",<br>  "logs",<br>  "secretsmanager",<br>  "monitoring",<br>  "sts",<br>  "ecr.api",<br>  "ecr.dkr"<br>]</pre> | no |
| <a name="input_isolated_subnet_cidrs"></a> [isolated\_subnet\_cidrs](#input\_isolated\_subnet\_cidrs) | 3 CIDRs for isolated (DB) subnets. | `list(string)` | n/a | yes |
| <a name="input_log_archive_bucket_arn"></a> [log\_archive\_bucket\_arn](#input\_log\_archive\_bucket\_arn) | ARN of the centralized log archive bucket for VPC flow logs. | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | 3 CIDRs for private subnets. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | 3 CIDRs for public subnets. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Use one NAT GW for all AZs (cost saving for non-prod). | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | Internet Gateway ID |
| <a name="output_isolated_subnet_ids"></a> [isolated\_subnet\_ids](#output\_isolated\_subnet\_ids) | Isolated subnet IDs |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | NAT Gateway IDs |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | VPC ARN |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | VPC CIDR block |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->