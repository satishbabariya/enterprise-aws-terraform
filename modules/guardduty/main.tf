resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  tags = var.tags
}

resource "aws_guardduty_detector_feature" "s3_logs" {
  detector_id = aws_guardduty_detector.this.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.this.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.this.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

# Runtime Monitoring: in-process threat detection for ECS Fargate, EC2, and EKS.
# This is GuardDuty's most significant 2023+ capability - detects behaviors
# happening INSIDE containers/instances, not just at the network/API level.
resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  count = var.enable_runtime_monitoring ? 1 : 0

  detector_id = aws_guardduty_detector.this.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = var.runtime_monitoring_ecs_fargate_addon_management ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = var.runtime_monitoring_ec2_agent_management ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.runtime_monitoring_eks_addon_management ? "ENABLED" : "DISABLED"
  }
}

# Legacy EKS Runtime Monitoring (predecessor; only enable if NOT using Runtime Monitoring above)
resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count = var.enable_eks_runtime_monitoring ? 1 : 0

  detector_id = aws_guardduty_detector.this.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.runtime_monitoring_eks_addon_management ? "ENABLED" : "DISABLED"
  }
}

resource "aws_guardduty_organization_admin_account" "this" {
  admin_account_id = var.delegated_admin_account_id
}

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable_organization_members = var.auto_enable_org_members
  detector_id                      = aws_guardduty_detector.this.id

  depends_on = [aws_guardduty_organization_admin_account.this]
}

# Org-wide feature configuration: ensures the same features are enabled across
# all member accounts (not just the delegated admin account).
resource "aws_guardduty_organization_configuration_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.this.id
  name        = "S3_DATA_EVENTS"
  auto_enable = var.auto_enable_org_members

  depends_on = [aws_guardduty_organization_configuration.this]
}

resource "aws_guardduty_organization_configuration_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EKS_AUDIT_LOGS"
  auto_enable = var.auto_enable_org_members

  depends_on = [aws_guardduty_organization_configuration.this]
}

resource "aws_guardduty_organization_configuration_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EBS_MALWARE_PROTECTION"
  auto_enable = var.auto_enable_org_members

  depends_on = [aws_guardduty_organization_configuration.this]
}

resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.this.id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = var.auto_enable_org_members

  depends_on = [aws_guardduty_organization_configuration.this]
}

resource "aws_guardduty_organization_configuration_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.this.id
  name        = "LAMBDA_NETWORK_LOGS"
  auto_enable = var.auto_enable_org_members

  depends_on = [aws_guardduty_organization_configuration.this]
}

resource "aws_guardduty_organization_configuration_feature" "runtime_monitoring" {
  count = var.enable_runtime_monitoring ? 1 : 0

  detector_id = aws_guardduty_detector.this.id
  name        = "RUNTIME_MONITORING"
  auto_enable = var.auto_enable_org_members

  additional_configuration {
    name        = "ECS_FARGATE_AGENT_MANAGEMENT"
    auto_enable = var.runtime_monitoring_ecs_fargate_addon_management ? var.auto_enable_org_members : "NONE"
  }

  additional_configuration {
    name        = "EC2_AGENT_MANAGEMENT"
    auto_enable = var.runtime_monitoring_ec2_agent_management ? var.auto_enable_org_members : "NONE"
  }

  additional_configuration {
    name        = "EKS_ADDON_MANAGEMENT"
    auto_enable = var.runtime_monitoring_eks_addon_management ? var.auto_enable_org_members : "NONE"
  }

  depends_on = [aws_guardduty_organization_configuration.this]
}
