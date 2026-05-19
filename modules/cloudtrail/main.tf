locals {
  trail_name       = "${var.org_name}-org-trail"
  log_group_name   = "/aws/cloudtrail/${local.trail_name}"
  metric_namespace = "CloudTrailMetrics"
  has_cw_logs      = var.enable_cloudwatch_logs
  has_alarms       = var.enable_cloudwatch_logs && var.alarms_sns_topic_arn != ""
}

# ============================================================
# CloudWatch Logs delivery (required for CIS metric filters)
# ============================================================
resource "aws_cloudwatch_log_group" "trail" {
  count = local.has_cw_logs ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
  log_group_class   = var.cloudwatch_log_group_class
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_iam_role" "cloudtrail_cw" {
  count = local.has_cw_logs ? 1 : 0

  name = "${var.org_name}-cloudtrail-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# The :* suffix matches log streams within this specific log group only.
# Scoped to a single ARN - AWS-documented pattern for log writers.
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "cloudtrail_cw" {
  count = local.has_cw_logs ? 1 : 0

  name = "cloudtrail-cw-policy"
  role = aws_iam_role.cloudtrail_cw[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.trail[0].arn}:*"
    }]
  })
}

# ============================================================
# Optional SNS topic for log file delivery notifications
# ============================================================
resource "aws_sns_topic" "delivery" {
  count = var.enable_delivery_notification ? 1 : 0

  name              = "${var.org_name}-cloudtrail-delivery"
  kms_master_key_id = var.kms_key_arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "delivery" {
  count = var.enable_delivery_notification ? 1 : 0

  arn = aws_sns_topic.delivery[0].arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.delivery[0].arn
    }]
  })
}

# ============================================================
# The Organization Trail
# ============================================================
resource "aws_cloudtrail" "org" {
  name                          = local.trail_name
  s3_bucket_name                = var.log_archive_bucket_name
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  sns_topic_name = var.enable_delivery_notification ? aws_sns_topic.delivery[0].name : null

  cloud_watch_logs_group_arn = local.has_cw_logs ? "${aws_cloudwatch_log_group.trail[0].arn}:*" : null
  cloud_watch_logs_role_arn  = local.has_cw_logs ? aws_iam_role.cloudtrail_cw[0].arn : null

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  insight_selector {
    insight_type = "ApiErrorRateInsight"
  }

  tags = var.tags
}

# ============================================================
# Trail-stopped alarm (alert if logging is disabled)
# ============================================================
resource "aws_cloudwatch_metric_alarm" "trail_logging_stopped" {
  count = local.has_alarms ? 1 : 0

  alarm_name          = "${var.org_name}-cloudtrail-logging-stopped"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Organization CloudTrail has not delivered events in 5 minutes - investigate immediately"
  treat_missing_data  = "breaching"

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.trail[0].name
  }

  alarm_actions = [var.alarms_sns_topic_arn]
  ok_actions    = [var.alarms_sns_topic_arn]
  tags          = var.tags
}

# ============================================================
# CIS 3.1-3.14 metric filters + alarms
# Pattern is uniform: filter pulls events matching a CIS rule,
# alarm fires on count >= 1 within a 5-minute period.
# ============================================================
locals {
  cis_metric_filters = {
    # CIS 3.1 - Unauthorized API calls
    unauthorized_api_calls = {
      pattern     = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
      description = "CIS 3.1 - Unauthorized API calls"
    }
    # CIS 3.2 - Console sign-in without MFA
    console_signin_no_mfa = {
      pattern     = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
      description = "CIS 3.2 - Console sign-in without MFA"
    }
    # CIS 3.3 - Root account use
    root_account_use = {
      pattern     = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
      description = "CIS 3.3 - Root account use"
    }
    # CIS 3.4 - IAM policy changes
    iam_policy_changes = {
      pattern     = "{ ($.eventName = DeleteGroupPolicy) || ($.eventName = DeleteRolePolicy) || ($.eventName = DeleteUserPolicy) || ($.eventName = PutGroupPolicy) || ($.eventName = PutRolePolicy) || ($.eventName = PutUserPolicy) || ($.eventName = CreatePolicy) || ($.eventName = DeletePolicy) || ($.eventName = CreatePolicyVersion) || ($.eventName = DeletePolicyVersion) || ($.eventName = AttachRolePolicy) || ($.eventName = DetachRolePolicy) || ($.eventName = AttachUserPolicy) || ($.eventName = DetachUserPolicy) || ($.eventName = AttachGroupPolicy) || ($.eventName = DetachGroupPolicy) }"
      description = "CIS 3.4 - IAM policy changes"
    }
    # CIS 3.5 - CloudTrail configuration changes
    cloudtrail_changes = {
      pattern     = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"
      description = "CIS 3.5 - CloudTrail config changes"
    }
    # CIS 3.6 - Console authentication failures
    console_auth_failures = {
      pattern     = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
      description = "CIS 3.6 - Console authentication failures"
    }
    # CIS 3.7 - Customer-managed KMS key disable/delete
    kms_cmk_changes = {
      pattern     = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"
      description = "CIS 3.7 - Customer-managed KMS key disable or schedule-delete"
    }
    # CIS 3.8 - S3 bucket policy changes
    s3_bucket_policy_changes = {
      pattern     = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"
      description = "CIS 3.8 - S3 bucket policy changes"
    }
    # CIS 3.9 - AWS Config changes
    aws_config_changes = {
      pattern     = "{ ($.eventSource = config.amazonaws.com) && (($.eventName = StopConfigurationRecorder) || ($.eventName = DeleteDeliveryChannel) || ($.eventName = PutDeliveryChannel) || ($.eventName = PutConfigurationRecorder)) }"
      description = "CIS 3.9 - AWS Config changes"
    }
    # CIS 3.10 - Security group changes
    security_group_changes = {
      pattern     = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup) }"
      description = "CIS 3.10 - Security group changes"
    }
    # CIS 3.11 - NACL changes
    nacl_changes = {
      pattern     = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"
      description = "CIS 3.11 - NACL changes"
    }
    # CIS 3.12 - Network gateway changes (IGW, NAT, VGW)
    network_gateway_changes = {
      pattern     = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"
      description = "CIS 3.12 - Network gateway changes"
    }
    # CIS 3.13 - Route table changes
    route_table_changes = {
      pattern     = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"
      description = "CIS 3.13 - Route table changes"
    }
    # CIS 3.14 - VPC changes
    vpc_changes = {
      pattern     = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"
      description = "CIS 3.14 - VPC changes"
    }
    # Bonus: Organizations changes (related to CIS 1.x organizational controls)
    organizations_changes = {
      pattern     = "{ ($.eventSource = organizations.amazonaws.com) && (($.eventName = AcceptHandshake) || ($.eventName = AttachPolicy) || ($.eventName = CreateAccount) || ($.eventName = CreateOrganizationalUnit) || ($.eventName = CreatePolicy) || ($.eventName = DeclineHandshake) || ($.eventName = DeleteOrganization) || ($.eventName = DeleteOrganizationalUnit) || ($.eventName = DeletePolicy) || ($.eventName = DetachPolicy) || ($.eventName = DisablePolicyType) || ($.eventName = EnablePolicyType) || ($.eventName = InviteAccountToOrganization) || ($.eventName = LeaveOrganization) || ($.eventName = MoveAccount) || ($.eventName = RemoveAccountFromOrganization) || ($.eventName = UpdatePolicy) || ($.eventName = UpdateOrganizationalUnit)) }"
      description = "AWS Organizations changes"
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "cis" {
  for_each = local.has_cw_logs ? local.cis_metric_filters : {}

  name           = "${var.org_name}-${each.key}"
  log_group_name = aws_cloudwatch_log_group.trail[0].name
  pattern        = each.value.pattern

  metric_transformation {
    name      = each.key
    namespace = local.metric_namespace
    value     = "1"
    unit      = "Count"

    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "cis" {
  for_each = local.has_alarms ? local.cis_metric_filters : {}

  alarm_name          = "${var.org_name}-cis-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.key
  namespace           = local.metric_namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = each.value.description
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.alarms_sns_topic_arn]
  tags          = var.tags
}

# ============================================================
# EventBridge auto-remediation rules
# Targets are downstream (passed via outputs.event_bus_arn or separate consumers)
# These rules fire on specific CloudTrail event types - your remediation lambdas
# subscribe via aws_cloudwatch_event_target in their own modules.
# ============================================================
resource "aws_cloudwatch_event_rule" "public_sg_ingress" {
  count = var.enable_eventbridge_remediation ? 1 : 0

  name        = "${var.org_name}-cloudtrail-public-sg-ingress"
  description = "Security group rule authorized 0.0.0.0/0 ingress - candidate for auto-revert"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["AuthorizeSecurityGroupIngress"]
      requestParameters = {
        ipPermissions = {
          items = {
            ipRanges = {
              items = {
                cidrIp = ["0.0.0.0/0"]
              }
            }
          }
        }
      }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "iam_access_key_created" {
  count = var.enable_eventbridge_remediation ? 1 : 0

  name        = "${var.org_name}-cloudtrail-iam-access-key-created"
  description = "Long-lived IAM access key created - forbidden by SCP but watch for delegated permissions"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["CreateAccessKey"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "iam_user_created" {
  count = var.enable_eventbridge_remediation ? 1 : 0

  name        = "${var.org_name}-cloudtrail-iam-user-created"
  description = "IAM user created - forbidden by SCP in workloads but always worth auditing"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["CreateUser"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "s3_public_access_change" {
  count = var.enable_eventbridge_remediation ? 1 : 0

  name        = "${var.org_name}-cloudtrail-s3-public-access-change"
  description = "Someone tried to disable S3 Block Public Access"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["PutBucketPublicAccessBlock", "PutAccountPublicAccessBlock", "DeleteBucketPublicAccessBlock"]
    }
  })

  tags = var.tags
}
