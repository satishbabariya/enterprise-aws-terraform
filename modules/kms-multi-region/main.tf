data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "EnableRootAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.additional_key_admins) > 0 ? [1] : []
    content {
      sid    = "KeyAdministrators"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.additional_key_admins
      }
      actions = [
        "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*",
        "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*",
        "kms:Get*", "kms:Delete*", "kms:TagResource", "kms:UntagResource",
        "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion",
        "kms:ReplicateKey", "kms:UpdatePrimaryRegion"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.additional_key_users) > 0 ? [1] : []
    content {
      sid    = "KeyUsers"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.additional_key_users
      }
      actions = [
        "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
        "kms:GenerateDataKey*", "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.service_principals) > 0 ? [1] : []
    content {
      sid    = "AllowServiceUse"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = var.service_principals
      }
      actions = [
        "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
        "kms:GenerateDataKey*", "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_kms_key" "primary" {
  provider = aws.primary

  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = true
  policy                  = data.aws_iam_policy_document.key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "primary" {
  provider      = aws.primary
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.primary.key_id
}

resource "aws_kms_replica_key" "secondary" {
  provider = aws.secondary

  description             = "${var.description} (replica)"
  deletion_window_in_days = var.deletion_window_in_days
  primary_key_arn         = aws_kms_key.primary.arn
  policy                  = data.aws_iam_policy_document.key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "secondary" {
  provider      = aws.secondary
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_replica_key.secondary.key_id
}
