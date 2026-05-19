output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA cert"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL - use for IRSA setup"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_role_arn" {
  description = "Node group IAM role ARN"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN - use as Federated principal in IRSA trust policies"
  value       = try(aws_iam_openid_connect_provider.this[0].arn, "")
}

output "oidc_issuer_hostname" {
  description = "OIDC issuer URL without https:// - use to build sub conditions like system:serviceaccount:<ns>:<sa>"
  value       = try(replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", ""), "")
}

output "addon_arns" {
  description = "Map of addon name to ARN"
  value       = { for k, v in aws_eks_addon.this : k => v.arn }
}

output "irsa_role_arns" {
  description = "Map of addon name to auto-created IRSA role ARN"
  value       = { for k, v in aws_iam_role.irsa : k => v.arn }
}
