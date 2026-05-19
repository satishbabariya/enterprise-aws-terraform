mock_provider "aws" {}
mock_provider "tls" {
  mock_data "tls_certificate" {
    defaults = {
      certificates = [{
        sha1_fingerprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
      }]
    }
  }
}

variables {
  name               = "test-cluster"
  private_subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
  kms_key_arn        = "arn:aws:kms:us-east-1:111111111111:key/abc"
}

run "cluster_private_endpoint_by_default" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_public_access == false
    error_message = "Public API endpoint must be disabled by default"
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access == true
    error_message = "Private API endpoint must be enabled"
  }
}

run "envelope_encryption_required" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].provider[0].key_arn == var.kms_key_arn
    error_message = "K8s secrets envelope encryption must use the supplied KMS key"
  }

  assert {
    condition     = contains(aws_eks_cluster.this.encryption_config[0].resources, "secrets")
    error_message = "Secrets resource must be in encryption_config"
  }
}

run "all_control_plane_logs_enabled_by_default" {
  command = plan

  assert {
    condition     = length(aws_eks_cluster.this.enabled_cluster_log_types) == 5
    error_message = "All 5 control plane log types (api/audit/authenticator/controllerManager/scheduler) must be enabled"
  }
}

run "oidc_provider_created_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 1
    error_message = "OIDC provider must be created by default (required for IRSA)"
  }
}

run "default_addons_installed" {
  command = plan

  assert {
    condition     = length(aws_eks_addon.this) == 4
    error_message = "4 default addons must be installed: vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver"
  }
}

run "irsa_roles_for_irsa_addons" {
  command = plan

  assert {
    condition     = length(aws_iam_role.irsa) == 2
    error_message = "2 IRSA roles must be auto-created (vpc-cni + aws-ebs-csi-driver)"
  }
}
