resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_iam_role" "cluster" {
  name = "${var.name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_aws_managed" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ])
  role       = aws_iam_role.cluster.name
  policy_arn = each.value
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.endpoint_public_access_cidrs : null
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role_policy_attachment.cluster_aws_managed,
  ]
}

# Managed node group
resource "aws_iam_role" "node" {
  name = "${var.name}-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_aws_managed" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ])
  role       = aws_iam_role.node.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-default"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_group_instance_types
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  scaling_config {
    min_size     = var.node_group_min_size
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.node_aws_managed]
}

# ============================================================
# IAM OIDC Identity Provider (IRSA)
# Required so workloads can assume IAM roles via Kubernetes ServiceAccounts.
# Without this, pods can only use the node instance role.
# ============================================================
data "tls_certificate" "oidc" {
  count = var.create_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = var.tags
}

# ============================================================
# IRSA roles for addons that need AWS API access
# ============================================================
locals {
  oidc_issuer_url   = var.create_oidc_provider ? replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "") : ""
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : ""

  # Which default addons need IRSA roles (when no explicit SA role provided)
  irsa_addon_specs = {
    "vpc-cni" = {
      namespace            = "kube-system"
      service_account_name = "aws-node"
      managed_policy_arn   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }
    "aws-ebs-csi-driver" = {
      namespace            = "kube-system"
      service_account_name = "ebs-csi-controller-sa"
      managed_policy_arn   = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  # Build the actual IRSA roles only for addons that:
  # 1. are enabled
  # 2. are in irsa_addon_specs
  # 3. have no explicit service_account_role_arn supplied
  irsa_roles_to_create = var.create_oidc_provider ? {
    for k, v in local.irsa_addon_specs : k => v
    if(
      lookup(var.managed_addons, k, null) != null &&
      lookup(var.managed_addons[k], "enabled", true) &&
      lookup(var.managed_addons[k], "service_account_role_arn", null) == null
    )
  } : {}
}

data "aws_iam_policy_document" "irsa_trust" {
  for_each = local.irsa_roles_to_create

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each = local.irsa_roles_to_create

  name               = "${var.name}-irsa-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust[each.key].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = local.irsa_roles_to_create

  role       = aws_iam_role.irsa[each.key].name
  policy_arn = each.value.managed_policy_arn
}

# ============================================================
# Managed EKS addons
# ============================================================
locals {
  enabled_addons = {
    for k, v in var.managed_addons : k => v
    if lookup(v, "enabled", true)
  }
}

resource "aws_eks_addon" "this" {
  for_each = local.enabled_addons

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.key
  addon_version = each.value.addon_version

  configuration_values = each.value.configuration_values

  service_account_role_arn = coalesce(
    each.value.service_account_role_arn,
    try(aws_iam_role.irsa[each.key].arn, null),
  )

  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

  depends_on = [aws_eks_node_group.this]

  tags = var.tags
}
