resource "aws_macie2_account" "this" {
  finding_publishing_frequency = var.finding_publishing_frequency
  status                       = "ENABLED"
}

resource "aws_macie2_organization_admin_account" "this" {
  admin_account_id = var.delegated_admin_account_id
  depends_on       = [aws_macie2_account.this]
}
