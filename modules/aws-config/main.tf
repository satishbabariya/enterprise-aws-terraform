resource "aws_iam_role" "config" {
  name = "${var.org_name}-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "this" {
  name     = "${var.org_name}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_sns_topic" "config" {
  count = var.create_sns_topic ? 1 : 0

  name              = "${var.org_name}-config-notifications"
  kms_master_key_id = var.kms_key_arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config" {
  count = var.create_sns_topic ? 1 : 0

  arn = aws_sns_topic.config[0].arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config[0].arn
    }]
  })
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.org_name}-config-delivery"
  s3_bucket_name = var.log_archive_bucket_name
  s3_key_prefix  = "config"
  s3_kms_key_arn = var.kms_key_arn
  sns_topic_arn  = var.create_sns_topic ? aws_sns_topic.config[0].arn : null

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_configuration_aggregator" "org" {
  name = "${var.org_name}-org-aggregator"
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config.arn
  }
  tags = var.tags
}

# Conformance packs: deploy AWS-managed compliance frameworks.
# template_s3_uri pulls the YAML from AWS's reference architecture bucket.
resource "aws_config_conformance_pack" "this" {
  for_each = var.conformance_packs

  name            = "${var.org_name}-${each.key}"
  template_s3_uri = each.value

  dynamic "input_parameter" {
    for_each = var.conformance_pack_delivery_bucket != "" ? [1] : []
    content {
      parameter_name  = "DeliveryS3Bucket"
      parameter_value = var.conformance_pack_delivery_bucket
    }
  }

  depends_on = [aws_config_configuration_recorder_status.this]
}

# Individually-enabled AWS-managed Config rules (in addition to conformance packs)
resource "aws_config_config_rule" "managed" {
  for_each = var.managed_rules

  name             = each.key
  description      = each.value.description != "" ? each.value.description : "Managed AWS Config rule: ${each.value.source_identifier}"
  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  depends_on = [aws_config_configuration_recorder_status.this]

  tags = var.tags
}
