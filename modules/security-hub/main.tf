resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = var.auto_enable_new_accounts
  auto_enable_standards = "NONE"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count         = var.enable_cis_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/3.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "pci" {
  count         = var.enable_pci_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:us-east-1::standards/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "nist" {
  count         = var.enable_nist_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:us-east-1::standards/nist-800-53/v/5.0.0"
  depends_on    = [aws_securityhub_account.this]
}
