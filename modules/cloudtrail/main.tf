resource "aws_iam_role" "cloudtrail_cw" {
  count = var.cloudwatch_log_group_arn != "" ? 1 : 0
  name  = "${var.org_name}-cloudtrail-cw-role"

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

resource "aws_iam_role_policy" "cloudtrail_cw" {
  count = var.cloudwatch_log_group_arn != "" ? 1 : 0
  name  = "cloudtrail-cw-policy"
  role  = aws_iam_role.cloudtrail_cw[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${var.cloudwatch_log_group_arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "org" {
  name                          = "${var.org_name}-org-trail"
  s3_bucket_name                = var.log_archive_bucket_name
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  cloud_watch_logs_group_arn = var.cloudwatch_log_group_arn != "" ? "${var.cloudwatch_log_group_arn}:*" : null
  cloud_watch_logs_role_arn  = var.cloudwatch_log_group_arn != "" ? aws_iam_role.cloudtrail_cw[0].arn : null

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

  tags = var.tags
}
