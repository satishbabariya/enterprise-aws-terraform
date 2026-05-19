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
