resource "aws_inspector2_enabler" "this" {
  account_ids    = [var.delegated_admin_account_id]
  resource_types = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]
}

resource "aws_inspector2_delegated_admin_account" "this" {
  account_id = var.delegated_admin_account_id
  depends_on = [aws_inspector2_enabler.this]
}

resource "aws_inspector2_organization_configuration" "this" {
  auto_enable {
    ec2         = var.auto_enable.ec2
    ecr         = var.auto_enable.ecr
    lambda      = var.auto_enable.lambda
    lambda_code = var.auto_enable.lambda_code
  }
  depends_on = [aws_inspector2_delegated_admin_account.this]
}
