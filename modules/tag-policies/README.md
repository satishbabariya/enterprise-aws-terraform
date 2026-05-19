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
| <a name="input_enforced_resource_types"></a> [enforced\_resource\_types](#input\_enforced\_resource\_types) | Resource types where tag policy enforcement is applied (prevents non-compliant tagging). | `list(string)` | <pre>[<br>  "ec2:instance",<br>  "ec2:volume",<br>  "s3:bucket",<br>  "rds:db",<br>  "rds:cluster",<br>  "dynamodb:table",<br>  "lambda:function",<br>  "ecs:cluster",<br>  "ecs:service",<br>  "eks:cluster",<br>  "elasticache:cluster"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the tag-policy resources themselves. | `map(string)` | `{}` | no |
| <a name="input_valid_compliance_scopes"></a> [valid\_compliance\_scopes](#input\_valid\_compliance\_scopes) | Allowed values for the ComplianceScope tag. | `list(string)` | <pre>[<br>  "none",<br>  "cis",<br>  "soc2",<br>  "pci",<br>  "hipaa",<br>  "all"<br>]</pre> | no |
| <a name="input_valid_data_classifications"></a> [valid\_data\_classifications](#input\_valid\_data\_classifications) | Allowed values for the DataClass tag. | `list(string)` | <pre>[<br>  "public",<br>  "internal",<br>  "confidential",<br>  "restricted"<br>]</pre> | no |
| <a name="input_valid_environments"></a> [valid\_environments](#input\_valid\_environments) | Allowed values for the Environment tag. | `list(string)` | <pre>[<br>  "prod",<br>  "staging",<br>  "dev",<br>  "sandbox",<br>  "shared",<br>  "management"<br>]</pre> | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | Tag policy ARN |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | Tag policy ID - attach this to OUs via aws\_organizations\_policy\_attachment |
<!-- END_TF_DOCS -->