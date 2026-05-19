resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_iam_role" "this" {
  name                 = "${var.name}-execution"
  permissions_boundary = var.permissions_boundary_arn != "" ? var.permissions_boundary_arn : null

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

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = length(var.vpc_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "insights" {
  count      = var.enable_lambda_insights ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

locals {
  effective_layers = concat(
    var.layers,
    var.enable_lambda_insights && var.lambda_insights_layer_arn != "" ? [var.lambda_insights_layer_arn] : [],
  )
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = aws_iam_role.this.arn

  package_type = var.image_uri != "" ? "Image" : "Zip"
  image_uri    = var.image_uri != "" ? var.image_uri : null
  filename     = var.image_uri == "" ? var.filename : null
  handler      = var.image_uri == "" ? var.handler : null
  runtime      = var.image_uri == "" ? var.runtime : null

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  architectures                  = var.architectures
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish_version

  layers      = length(local.effective_layers) > 0 ? local.effective_layers : null
  kms_key_arn = var.kms_key_arn

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_topic_arn != "" ? [1] : []
    content {
      target_arn = var.dead_letter_topic_arn
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.basic,
  ]
}

resource "aws_lambda_function_url" "this" {
  count = var.function_url_enabled ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_authorization_type
}
