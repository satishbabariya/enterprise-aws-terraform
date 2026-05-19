data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_securityhub_account" "this" {
  enable_default_standards = false
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = var.auto_enable_new_accounts
  auto_enable_standards = "NONE"

  depends_on = [aws_securityhub_account.this]
}

# ----- Standards -----
resource "aws_securityhub_standards_subscription" "cis" {
  count         = var.enable_cis_standard ? 1 : 0
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:::ruleset/cis-aws-foundations-benchmark/v/3.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "pci" {
  count         = var.enable_pci_standard ? 1 : 0
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "nist" {
  count         = var.enable_nist_standard ? 1 : 0
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.region}::standards/nist-800-53/v/5.0.0"
  depends_on    = [aws_securityhub_account.this]
}

# ----- Finding aggregator (multi-region) -----
# Aggregates findings from multiple regions into the current region.
resource "aws_securityhub_finding_aggregator" "this" {
  count = length(var.finding_aggregator_regions) > 0 ? 1 : 0

  linking_mode = contains(var.finding_aggregator_regions, "*") ? "ALL_REGIONS" : "SPECIFIED_REGIONS"

  specified_regions = contains(var.finding_aggregator_regions, "*") ? null : var.finding_aggregator_regions

  depends_on = [aws_securityhub_account.this]
}

# ----- Product subscriptions -----
locals {
  product_arn_names = {
    guardduty        = "guardduty"
    inspector        = "inspector"
    macie            = "macie"
    config           = "config"
    access_analyzer  = "access-analyzer"
    firewall_manager = "firewall-manager"
  }

  enabled_product_subscriptions = {
    for k, v in {
      guardduty        = lookup(var.product_subscriptions, "guardduty", true)
      inspector        = lookup(var.product_subscriptions, "inspector", true)
      macie            = lookup(var.product_subscriptions, "macie", true)
      config           = lookup(var.product_subscriptions, "config", true)
      access_analyzer  = lookup(var.product_subscriptions, "access_analyzer", true)
      firewall_manager = lookup(var.product_subscriptions, "firewall_manager", false)
    } : k => k
    if v == true
  }
}

resource "aws_securityhub_product_subscription" "this" {
  for_each = local.enabled_product_subscriptions

  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.region}::product/aws/${local.product_arn_names[each.key]}"

  depends_on = [aws_securityhub_account.this]
}

# ----- Automation rules (auto-suppress accepted findings) -----
resource "aws_securityhub_automation_rule" "suppress" {
  for_each = var.suppressed_controls

  rule_name   = "Suppress-${each.key}"
  description = "Auto-suppress: ${each.value.disabled_reason}"
  rule_order  = each.value.rule_order
  rule_status = "ENABLED"
  is_terminal = true

  criteria {
    compliance_security_control_id {
      comparison = "EQUALS"
      value      = each.key
    }
    compliance_status {
      comparison = "EQUALS"
      value      = "FAILED"
    }
    record_state {
      comparison = "EQUALS"
      value      = "ACTIVE"
    }
  }

  actions {
    type = "FINDING_FIELDS_UPDATE"
    finding_fields_update {
      workflow {
        status = "SUPPRESSED"
      }
      note {
        text       = each.value.disabled_reason
        updated_by = "terraform-securityhub-automation"
      }
    }
  }

  depends_on = [aws_securityhub_account.this]
}
