mock_provider "aws" {}

variables {
  name        = "test-table"
  hash_key    = "id"
  kms_key_arn = "arn:aws:kms:us-east-1:111111111111:key/abc"
}

run "sse_enabled" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.server_side_encryption[0].enabled == true
    error_message = "SSE must be enabled"
  }

  assert {
    condition     = aws_dynamodb_table.this.server_side_encryption[0].kms_key_arn == var.kms_key_arn
    error_message = "Must use supplied KMS key"
  }
}

run "pitr_enabled" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.point_in_time_recovery[0].enabled == true
    error_message = "PITR must be enabled"
  }
}

run "deletion_protection_on" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.deletion_protection_enabled == true
    error_message = "Deletion protection must be on"
  }
}

run "global_secondary_index_added" {
  command = plan

  variables {
    additional_attributes = [
      { name = "status", type = "S" },
      { name = "created_at", type = "N" },
    ]
    global_secondary_indexes = [{
      name            = "status-created-index"
      hash_key        = "status"
      range_key       = "created_at"
      projection_type = "ALL"
    }]
  }

  assert {
    condition     = length(aws_dynamodb_table.this.global_secondary_index) == 1
    error_message = "GSI must be added when supplied"
  }

  assert {
    condition     = length(aws_dynamodb_table.this.attribute) == 3
    error_message = "Hash key + 2 additional attributes = 3 attribute blocks"
  }
}

run "global_table_enables_streams_automatically" {
  command = plan

  variables {
    global_table_regions = ["us-west-2"]
  }

  assert {
    condition     = aws_dynamodb_table.this.stream_enabled == true
    error_message = "Streams must be auto-enabled when global table replicas are configured"
  }

  assert {
    condition     = length(aws_dynamodb_table.this.replica) == 1
    error_message = "Replica must be created when global_table_regions is set"
  }
}
