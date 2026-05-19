# Session preferences: forces S3 + KMS logging, sets idle timeout
resource "aws_ssm_document" "session_preferences" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "${var.org_name}-${var.account_name} Session Manager preferences"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = element(split(":", var.session_log_bucket_arn), 5)
      s3KeyPrefix                 = "session-manager/${var.account_name}/"
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.sessions.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      kmsKeyId                    = var.session_log_kms_key_arn
      idleSessionTimeout          = tostring(var.session_idle_timeout_minutes)
      maxSessionDuration          = tostring(var.session_max_duration_minutes)
      runAsEnabled                = false
      shellProfile = {
        linux = var.shell_profile_linux
      }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "sessions" {
  name              = "/aws/ssm/${var.org_name}-${var.account_name}-sessions"
  retention_in_days = 365
  kms_key_id        = var.session_log_kms_key_arn
  tags              = var.tags
}

# Instance profile role - attach to EC2 instances to allow SSM session access
resource "aws_iam_role" "instance" {
  name = "${var.org_name}-${var.account_name}-ssm-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.org_name}-${var.account_name}-ssm-instance-profile"
  role = aws_iam_role.instance.name
  tags = var.tags
}
