locals {
  bucket_name = "${var.org_name}-${var.region}-log-archive"
}

# This bucket IS the centralized logging destination for every other bucket
# in the org. Self-logging would create an infinite loop of access events.
# Trail integrity is protected by S3 Object Lock + KMS + bucket policy.
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "logs" {
  bucket              = local.bucket_name
  object_lock_enabled = true
  lifecycle { prevent_destroy = true }
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_object_lock_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.object_lock_retention_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disable ACLs entirely - all access controlled via bucket policy + IAM.
# This is the AWS recommendation as of 2023 (was BucketOwnerPreferred before).
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    filter {}
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  # Blanket deny: anything not from this AWS Organization or an AWS service.
  # Defense in depth - the public access block already exists; this also blocks
  # cross-org cross-account principals attempting to use the bucket.
  statement {
    sid    = "DenyExternalPrincipals"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"]
    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:PrincipalOrgID"
      values   = [var.org_id]
    }
    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
  }

  # All traffic must be TLS
  statement {
    sid    = "DenyNonSecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # CloudTrail PutObject - tightly scoped:
  #   - org-wide via aws:SourceOrgID
  #   - source account = management (aws:SourceAccount) to prevent confused deputy
  #   - if expected_cloudtrail_arn is supplied, also pin to that exact trail ARN
  #   - require bucket-owner-full-control ACL (AWS best practice)
  statement {
    sid    = "AllowOrgCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/cloudtrail/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [var.org_id]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.management_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    dynamic "condition" {
      for_each = var.expected_cloudtrail_arn != "" ? [1] : []
      content {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.expected_cloudtrail_arn]
      }
    }
  }

  # CloudTrail bucket ACL check - read-only, scoped to management account
  statement {
    sid    = "AllowCloudTrailGetBucketAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.management_account_id]
    }

    dynamic "condition" {
      for_each = var.expected_cloudtrail_arn != "" ? [1] : []
      content {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.expected_cloudtrail_arn]
      }
    }
  }

  # AWS Config writes - org-wide, optionally pinned to specific aggregator accounts
  statement {
    sid    = "AllowConfigWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["s3:PutObject", "s3:GetBucketAcl"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/config/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [var.org_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    dynamic "condition" {
      for_each = length(var.expected_config_account_ids) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = var.expected_config_account_ids
      }
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_bucket_policy.json
}

# Cross-region replication: requires a destination bucket in the secondary region.
# Provision the replica bucket separately (a second invocation of this module aliased
# to the secondary region with replication disabled), then pass its ARN here.

resource "aws_iam_role" "replication" {
  count = var.replica_bucket_arn != "" ? 1 : 0

  name = "${var.org_name}-log-archive-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "replication" {
  count = var.replica_bucket_arn != "" ? 1 : 0

  name = "replication-policy"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
        Resource = aws_s3_bucket.logs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.logs.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${var.replica_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt"
        ]
        Resource = var.replica_kms_key_arn
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "logs" {
  count = var.replica_bucket_arn != "" ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    filter {}

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = var.replica_bucket_arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = var.replica_kms_key_arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.logs]
}

# ============================================================
# Cross-account AuditReader role
# Lives in this (log-archive) account; trusted by the security account
# so auditors / IR analysts can list + read logs without granting
# them broad bucket access via S3 IAM in their own account.
# ============================================================
locals {
  create_audit_role = length(var.audit_reader_principal_arns) > 0
}

data "aws_iam_policy_document" "audit_reader_trust" {
  count = local.create_audit_role ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.audit_reader_principal_arns
    }
    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.audit_reader_external_id != "" ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.audit_reader_external_id]
      }
    }
  }
}

data "aws_iam_policy_document" "audit_reader_permissions" {
  count = local.create_audit_role ? 1 : 0

  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
    ]
    resources = [aws_s3_bucket.logs.arn]
  }

  statement {
    sid    = "ReadObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging",
    ]
    resources = ["${aws_s3_bucket.logs.arn}/*"]
  }

  statement {
    sid    = "DecryptLogs"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = [var.kms_key_arn]
  }

  # Explicit deny on all mutating operations
  statement {
    sid    = "DenyMutations"
    effect = "Deny"
    actions = [
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:DeleteBucket*",
      "s3:PutBucket*",
      "s3:PutBucketPolicy",
      "s3:PutBucketAcl",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:BypassGovernanceRetention",
    ]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*",
    ]
  }
}

resource "aws_iam_role" "audit_reader" {
  count = local.create_audit_role ? 1 : 0

  name                 = "${var.org_name}-log-archive-audit-reader"
  description          = "Cross-account read-only role over the centralized log archive bucket"
  assume_role_policy   = data.aws_iam_policy_document.audit_reader_trust[0].json
  max_session_duration = 3600 # 1 hour - force re-assumption for long investigations

  tags = var.tags
}

resource "aws_iam_role_policy" "audit_reader" {
  count = local.create_audit_role ? 1 : 0

  name   = "log-archive-read-and-decrypt"
  role   = aws_iam_role.audit_reader[0].id
  policy = data.aws_iam_policy_document.audit_reader_permissions[0].json
}
