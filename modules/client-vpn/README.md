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
| <a name="input_allowed_routes"></a> [allowed\_routes](#input\_allowed\_routes) | Destination CIDRs reachable through the VPN. Add VPC CIDR + any peered networks. | `list(string)` | n/a | yes |
| <a name="input_authorize_groups"></a> [authorize\_groups](#input\_authorize\_groups) | SAML group SIDs allowed to connect. Empty allows all authenticated users. | `list(string)` | `[]` | no |
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | CIDR block for VPN client IPs (must be /22 or larger, not overlapping VPC). | `string` | `"10.255.0.0/22"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | CloudWatch log group for connection logs. | `string` | n/a | yes |
| <a name="input_mutual_auth_root_ca_arn"></a> [mutual\_auth\_root\_ca\_arn](#input\_mutual\_auth\_root\_ca\_arn) | Root CA ACM ARN for certificate-based mutual auth. Set when SAML is not used. | `string` | `""` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Short lowercase org name. | `string` | n/a | yes |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn) | IAM SAML provider ARN for federated user authentication. Empty disables SAML auth. | `string` | `""` | no |
| <a name="input_self_service_saml_provider_arn"></a> [self\_service\_saml\_provider\_arn](#input\_self\_service\_saml\_provider\_arn) | Optional separate SAML provider for the self-service portal. | `string` | `""` | no |
| <a name="input_server_certificate_arn"></a> [server\_certificate\_arn](#input\_server\_certificate\_arn) | ACM certificate ARN for the VPN server. Issue via AWS Private CA or import. | `string` | n/a | yes |
| <a name="input_session_timeout_hours"></a> [session\_timeout\_hours](#input\_session\_timeout\_hours) | Maximum session duration: 8, 10, 12, or 24. | `number` | `12` | no |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | Split tunneling - only VPC-bound traffic uses the VPN. Best for performance + privacy. | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs (one per AZ) for the Client VPN ENIs. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where Client VPN endpoints are created. | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_dns_name"></a> [endpoint\_dns\_name](#output\_endpoint\_dns\_name) | DNS name clients connect to |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | Client VPN endpoint ID |
| <a name="output_self_service_portal_url"></a> [self\_service\_portal\_url](#output\_self\_service\_portal\_url) | Self-service portal URL (federated auth only) |
<!-- END_TF_DOCS -->