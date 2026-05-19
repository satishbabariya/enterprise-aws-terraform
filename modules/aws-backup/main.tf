resource "aws_backup_vault" "this" {
  name        = "${var.org_name}-central-backup-vault"
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

resource "aws_backup_vault_lock_configuration" "this" {
  count = var.vault_lock_changeable_for_days > 0 ? 1 : 0

  backup_vault_name   = aws_backup_vault.this.name
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.vault_lock_min_retention_days
}

resource "aws_iam_role" "backup" {
  name = "${var.org_name}-aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  name = "${var.org_name}-default-backup-plan"

  rule {
    rule_name           = "daily"
    target_vault_name   = aws_backup_vault.this.name
    schedule            = "cron(0 5 ? * * *)"
    start_window        = 60
    completion_window   = 360
    recovery_point_tags = var.tags

    lifecycle {
      delete_after = var.daily_backup_retention_days
    }

    dynamic "copy_action" {
      for_each = var.cross_region_copy_destination != "" ? [1] : []
      content {
        destination_vault_arn = var.cross_region_copy_destination
        lifecycle {
          delete_after = var.daily_backup_retention_days
        }
      }
    }
  }

  rule {
    rule_name           = "weekly"
    target_vault_name   = aws_backup_vault.this.name
    schedule            = "cron(0 5 ? * SUN *)"
    start_window        = 60
    completion_window   = 480
    recovery_point_tags = var.tags

    lifecycle {
      cold_storage_after = 30
      delete_after       = var.weekly_backup_retention_days
    }
  }

  rule {
    rule_name           = "monthly"
    target_vault_name   = aws_backup_vault.this.name
    schedule            = "cron(0 5 1 * ? *)"
    start_window        = 60
    completion_window   = 720
    recovery_point_tags = var.tags

    lifecycle {
      cold_storage_after = 30
      delete_after       = var.monthly_backup_retention_days
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "by_tag" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.org_name}-backup-by-tag"
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}
