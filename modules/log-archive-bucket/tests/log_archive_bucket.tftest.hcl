mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
    }
  }
}

variables {
  org_name              = "testorg"
  region                = "us-east-1"
  org_id                = "o-test123abc"
  management_account_id = "111111111111"
  kms_key_arn           = "arn:aws:kms:us-east-1:111111111111:key/abc123"
}

run "bucket_has_object_lock_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket.logs.object_lock_enabled == true
    error_message = "Object Lock must be enabled at bucket creation - cannot be added later"
  }
}

run "object_lock_minimum_365_days" {
  command = plan

  assert {
    condition     = aws_s3_bucket_object_lock_configuration.logs.rule[0].default_retention[0].days >= 365
    error_message = "Object Lock retention must be at least 365 days for PCI-DSS / HIPAA"
  }
}

run "object_lock_validation_rejects_under_365" {
  command = plan

  variables {
    object_lock_retention_days = 30
  }

  expect_failures = [
    var.object_lock_retention_days,
  ]
}

run "public_access_fully_blocked" {
  command = plan

  assert {
    condition = (
      aws_s3_bucket_public_access_block.logs.block_public_acls &&
      aws_s3_bucket_public_access_block.logs.block_public_policy &&
      aws_s3_bucket_public_access_block.logs.ignore_public_acls &&
      aws_s3_bucket_public_access_block.logs.restrict_public_buckets
    )
    error_message = "All four public-access-block flags must be true"
  }
}

run "ownership_enforced" {
  command = plan

  assert {
    condition     = aws_s3_bucket_ownership_controls.logs.rule[0].object_ownership == "BucketOwnerEnforced"
    error_message = "Ownership must be BucketOwnerEnforced (ACLs disabled)"
  }
}

run "no_audit_role_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role.audit_reader) == 0
    error_message = "AuditReader role must NOT be created when audit_reader_principal_arns is empty"
  }
}

run "audit_role_created_when_principals_supplied" {
  command = plan

  variables {
    audit_reader_principal_arns = ["arn:aws:iam::222222222222:root"]
  }

  assert {
    condition     = length(aws_iam_role.audit_reader) == 1
    error_message = "AuditReader role must be created when principals are supplied"
  }

  assert {
    condition     = aws_iam_role.audit_reader[0].max_session_duration == 3600
    error_message = "AuditReader session must be 1 hour for re-assumption audit trail"
  }
}

run "replication_disabled_by_default" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_replication_configuration.logs) == 0
    error_message = "CRR must NOT be configured when replica_bucket_arn is empty"
  }
}

run "replication_enabled_when_replica_supplied" {
  command = plan

  variables {
    replica_bucket_arn  = "arn:aws:s3:::testorg-us-west-2-log-archive"
    replica_kms_key_arn = "arn:aws:kms:us-west-2:111111111111:key/def456"
  }

  assert {
    condition     = length(aws_s3_bucket_replication_configuration.logs) == 1
    error_message = "CRR must be configured when replica_bucket_arn is supplied"
  }
}
