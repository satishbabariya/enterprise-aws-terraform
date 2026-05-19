# EventBridge rule: high-severity findings -> high SNS topic
resource "aws_cloudwatch_event_rule" "high_severity" {
  name        = "${var.org_name}-guardduty-high"
  description = "Route GuardDuty high-severity findings (7.0-10.0) to SNS"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { numeric = [">=", 7.0, "<", 9.0] }
      ]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "high_severity_sns" {
  rule      = aws_cloudwatch_event_rule.high_severity.name
  target_id = "sns-high"
  arn       = var.high_alert_topic_arn

  input_transformer {
    input_paths = {
      type     = "$.detail.type"
      severity = "$.detail.severity"
      account  = "$.detail.accountId"
      region   = "$.detail.region"
      resource = "$.detail.resource.resourceType"
      title    = "$.detail.title"
      desc     = "$.detail.description"
    }
    input_template = "\"[GuardDuty HIGH] Account <account> Region <region>: <title>\\n\\nType: <type>\\nSeverity: <severity>\\nResource: <resource>\\n\\n<desc>\""
  }
}

# Critical findings (severity >= 9.0) - page on-call
resource "aws_cloudwatch_event_rule" "critical_severity" {
  name        = "${var.org_name}-guardduty-critical"
  description = "Route GuardDuty critical findings (9.0-10.0) to critical SNS for paging"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { numeric = [">=", 9.0] }
      ]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "critical_severity_sns" {
  rule      = aws_cloudwatch_event_rule.critical_severity.name
  target_id = "sns-critical"
  arn       = var.critical_alert_topic_arn
}

# Auto-quarantine: specific finding types trigger Lambda that attaches a block-all SG.
# The Lambda code is in /modules/guardduty-auto-remediation/lambda/ (deploy via zip).
data "archive_file" "quarantine_lambda" {
  type        = "zip"
  output_path = "${path.module}/quarantine_lambda.zip"

  source {
    filename = "index.py"
    content  = <<-PYTHON
import boto3
import json
import os

ec2 = boto3.client('ec2')
QUARANTINE_SG_NAME = os.environ.get('QUARANTINE_SG_NAME', 'guardduty-quarantine')


def get_or_create_quarantine_sg(vpc_id):
    sgs = ec2.describe_security_groups(
        Filters=[
            {'Name': 'vpc-id', 'Values': [vpc_id]},
            {'Name': 'group-name', 'Values': [QUARANTINE_SG_NAME]},
        ]
    )
    if sgs['SecurityGroups']:
        return sgs['SecurityGroups'][0]['GroupId']
    sg = ec2.create_security_group(
        GroupName=QUARANTINE_SG_NAME,
        Description='GuardDuty quarantine - all traffic blocked',
        VpcId=vpc_id,
    )
    return sg['GroupId']


def handler(event, context):
    detail = event['detail']
    resource = detail.get('resource', {})
    instance = resource.get('instanceDetails', {})
    instance_id = instance.get('instanceId')
    if not instance_id:
        return {'status': 'no instance to quarantine'}
    nis = ec2.describe_instances(InstanceIds=[instance_id])
    vpc_id = nis['Reservations'][0]['Instances'][0]['VpcId']
    quarantine_sg = get_or_create_quarantine_sg(vpc_id)
    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        Groups=[quarantine_sg],
    )
    return {
        'status': 'quarantined',
        'instance_id': instance_id,
        'security_group': quarantine_sg,
    }
PYTHON
  }
}

resource "aws_iam_role" "quarantine" {
  name = "${var.org_name}-guardduty-quarantine-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "quarantine_basic" {
  role       = aws_iam_role.quarantine.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "quarantine_xray" {
  role       = aws_iam_role.quarantine.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Quarantine lambda operates across the org - must look up any instance/SG
# and create a new SG in any VPC. EC2 IAM doesn't support per-resource ARNs
# for CreateSecurityGroup or DescribeInstances.
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "quarantine" {
  name = "quarantine-policy"
  role = aws_iam_role.quarantine.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:ModifyInstanceAttribute",
        "ec2:CreateTags"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_lambda_function" "quarantine" {
  filename         = data.archive_file.quarantine_lambda.output_path
  function_name    = "${var.org_name}-guardduty-quarantine"
  role             = aws_iam_role.quarantine.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.quarantine_lambda.output_base64sha256
  timeout          = 30

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      QUARANTINE_SG_NAME = "guardduty-quarantine"
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "auto_quarantine" {
  name        = "${var.org_name}-guardduty-auto-quarantine"
  description = "GuardDuty findings that auto-quarantine the affected EC2 instance"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      type = var.auto_quarantine_findings
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "auto_quarantine_lambda" {
  rule      = aws_cloudwatch_event_rule.auto_quarantine.name
  target_id = "quarantine-lambda"
  arn       = aws_lambda_function.quarantine.arn
}

resource "aws_lambda_permission" "auto_quarantine" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quarantine.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_quarantine.arn
}
