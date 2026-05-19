resource "aws_cloudtrail_event_data_store" "this" {
  name = "${var.org_name}-cloudtrail-lake"

  multi_region_enabled           = true
  organization_enabled           = var.is_organization_event_data_store
  termination_protection_enabled = true
  retention_period               = var.retention_days
  kms_key_id                     = var.kms_key_arn

  # Capture management events (always on if include_management_events)
  dynamic "advanced_event_selector" {
    for_each = var.include_management_events ? [1] : []
    content {
      name = "Management events"

      field_selector {
        field  = "eventCategory"
        equals = ["Management"]
      }
    }
  }

  # S3 data events
  dynamic "advanced_event_selector" {
    for_each = var.include_s3_data_events ? [1] : []
    content {
      name = "S3 data events"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::S3::Object"]
      }
    }
  }

  # Lambda data events
  dynamic "advanced_event_selector" {
    for_each = var.include_lambda_data_events ? [1] : []
    content {
      name = "Lambda data events"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::Lambda::Function"]
      }
    }
  }

  tags = var.tags
}
