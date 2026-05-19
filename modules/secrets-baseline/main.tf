module "kms" {
  source      = "../kms"
  account_id  = var.account_id
  description = "KMS key for Secrets Manager secrets in this account"
  key_alias   = "${var.org_name}-${var.account_name}-secrets"
  tags        = var.tags
}

# Service-linked role for Secrets Manager rotation Lambdas.
# Application secrets created elsewhere should be encrypted with module.kms.key_arn.
resource "aws_iam_role" "rotation_lambda" {
  name = "${var.org_name}-${var.account_name}-secrets-rotation-lambda"

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

resource "aws_iam_role_policy_attachment" "rotation_basic" {
  role       = aws_iam_role.rotation_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "rotation_vpc" {
  role       = aws_iam_role.rotation_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "rotation_secrets" {
  name = "secrets-rotation-policy"
  role = aws_iam_role.rotation_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = "arn:aws:secretsmanager:*:${var.account_id}:secret:*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetRandomPassword"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = module.kms.key_arn
      }
    ]
  })
}

# Config rule: alert on secrets that have not been rotated within max_secret_age_days
resource "aws_config_config_rule" "secret_rotation" {
  name        = "${var.org_name}-${var.account_name}-secret-rotation-check"
  description = "Flags Secrets Manager secrets that have not been rotated in time"

  source {
    owner             = "AWS"
    source_identifier = "SECRETSMANAGER_ROTATION_ENABLED_CHECK"
  }

  input_parameters = jsonencode({
    maximumAllowedRotationFrequency = var.max_secret_age_days
  })

  tags = var.tags
}
