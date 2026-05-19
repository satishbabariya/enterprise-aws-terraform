resource "aws_sns_topic" "by_severity" {
  for_each = toset(var.severities)

  name              = "${var.org_name}-alerts-${each.key}"
  kms_master_key_id = var.kms_key_id
  tags              = var.tags
}

data "aws_iam_policy_document" "topic_policy" {
  for_each = aws_sns_topic.by_severity

  statement {
    sid    = "AllowOrgServicesToPublish"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com",
        "budgets.amazonaws.com",
        "securityhub.amazonaws.com",
        "guardduty.amazonaws.com",
        "config.amazonaws.com",
      ]
    }
    actions   = ["SNS:Publish"]
    resources = [each.value.arn]
  }

  statement {
    sid    = "DenyNonSecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["SNS:Publish"]
    resources = [each.value.arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sns_topic_policy" "by_severity" {
  for_each = aws_sns_topic.by_severity

  arn    = each.value.arn
  policy = data.aws_iam_policy_document.topic_policy[each.key].json
}

resource "aws_sns_topic_subscription" "pagerduty_critical" {
  count = var.pagerduty_critical_endpoint != "" ? 1 : 0

  topic_arn              = aws_sns_topic.by_severity["critical"].arn
  protocol               = "https"
  endpoint               = var.pagerduty_critical_endpoint
  endpoint_auto_confirms = true
}

resource "aws_sns_topic_subscription" "pagerduty_high" {
  count = var.pagerduty_high_endpoint != "" ? 1 : 0

  topic_arn              = aws_sns_topic.by_severity["high"].arn
  protocol               = "https"
  endpoint               = var.pagerduty_high_endpoint
  endpoint_auto_confirms = true
}

resource "aws_cloudwatch_event_bus" "central" {
  name = "${var.org_name}-central-bus"
  tags = var.tags
}

resource "aws_cloudwatch_event_archive" "central" {
  name             = "${var.org_name}-central-archive"
  event_source_arn = aws_cloudwatch_event_bus.central.arn
  description      = "Central event archive for replay and audit"
  retention_days   = 365
}

resource "aws_iam_role" "chatbot" {
  count = var.slack_workspace_id != "" ? 1 : 0

  name = "${var.org_name}-chatbot-slack-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "chatbot.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "chatbot_readonly" {
  count = var.slack_workspace_id != "" ? 1 : 0

  role       = aws_iam_role.chatbot[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}

# NOTE: AWS Chatbot Slack channel config is not yet a first-class Terraform resource
# in all providers. After applying this module, finish wiring by running:
#   aws chatbot create-slack-channel-configuration \
#     --configuration-name <org>-slack-alerts \
#     --iam-role-arn <chatbot_role_arn> \
#     --slack-channel-id <slack_channel_id> \
#     --slack-workspace-id <slack_workspace_id> \
#     --sns-topic-arns <medium/low/info topic ARNs>
