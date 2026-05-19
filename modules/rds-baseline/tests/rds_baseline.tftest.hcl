mock_provider "aws" {}

variables {
  name                       = "test-db"
  engine                     = "postgres"
  engine_version             = "16.3"
  instance_class             = "db.r6g.large"
  vpc_id                     = "vpc-abc"
  isolated_subnet_ids        = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
  kms_key_arn                = "arn:aws:kms:us-east-1:111111111111:key/abc"
  db_name                    = "appdb"
  allowed_security_group_ids = []
}

run "encryption_required" {
  command = plan

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Storage must be encrypted"
  }

  assert {
    condition     = aws_db_instance.this.kms_key_id == var.kms_key_arn
    error_message = "Must use supplied KMS key"
  }
}

run "managed_master_password" {
  command = plan

  assert {
    condition     = aws_db_instance.this.manage_master_user_password == true
    error_message = "Master password must be managed by Secrets Manager"
  }
}

run "deletion_protection_default_on" {
  command = plan

  assert {
    condition     = aws_db_instance.this.deletion_protection == true
    error_message = "Deletion protection must be on by default"
  }
}

run "not_publicly_accessible" {
  command = plan

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "RDS must not be publicly accessible"
  }
}

run "iam_db_auth_on" {
  command = plan

  assert {
    condition     = aws_db_instance.this.iam_database_authentication_enabled == true
    error_message = "IAM DB auth must be enabled"
  }
}

run "backup_tag_present" {
  command = plan

  assert {
    condition     = lookup(aws_db_instance.this.tags, "Backup", "") == "true"
    error_message = "Backup=true tag must be present (selects for AWS Backup plan)"
  }
}

run "engine_validation" {
  command = plan

  variables {
    engine = "oracle-se2"
  }

  expect_failures = [var.engine]
}

run "blue_green_supports_zero_downtime_upgrade" {
  command = plan

  variables {
    blue_green_update_enabled = true
  }

  assert {
    condition     = aws_db_instance.this.blue_green_update[0].enabled == true
    error_message = "Blue/green must be configurable via the new variable"
  }
}

run "gp3_iops_and_throughput_passthrough" {
  command = plan

  variables {
    iops               = 12000
    storage_throughput = 500
  }

  assert {
    condition     = aws_db_instance.this.iops == 12000
    error_message = "IOPS must pass through"
  }

  assert {
    condition     = aws_db_instance.this.storage_throughput == 500
    error_message = "Throughput must pass through"
  }
}
