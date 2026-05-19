locals {
  has_allowlist = length(var.domain_allowlist) > 0
}

# Stateful rule group: domain allowlist (egress)
resource "aws_networkfirewall_rule_group" "domain_allowlist" {
  count    = local.has_allowlist ? 1 : 0
  capacity = 100
  name     = "${var.org_name}-egress-domain-allowlist"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.domain_allowlist
      }
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = var.tags
}

# Stateless drop-broadcast rule group
resource "aws_networkfirewall_rule_group" "drop_invalid" {
  capacity = 100
  name     = "${var.org_name}-stateless-drop-invalid"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              # Drop traffic to multicast/broadcast and link-local
              destination {
                address_definition = "224.0.0.0/4"
              }
              source {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.org_name}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:drop_strict", "aws:alert_strict"]

    stateful_engine_options {
      rule_order              = "STRICT_ORDER"
      stream_exception_policy = "DROP"
    }

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.drop_invalid.arn
    }

    dynamic "stateful_rule_group_reference" {
      for_each = local.has_allowlist ? [1] : []
      content {
        priority     = 100
        resource_arn = aws_networkfirewall_rule_group.domain_allowlist[0].arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = var.enable_managed_rule_groups ? toset([
        "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/ThreatSignaturesBotnetWebStrictOrder",
        "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/ThreatSignaturesMalwareStrictOrder",
      ]) : []
      content {
        priority     = 200
        resource_arn = stateful_rule_group_reference.value
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.org_name}-network-firewall"
  vpc_id              = var.vpc_id
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn

  dynamic "subnet_mapping" {
    for_each = toset(var.firewall_subnet_ids)
    content {
      subnet_id = subnet_mapping.value
    }
  }

  delete_protection                 = true
  firewall_policy_change_protection = false
  subnet_change_protection          = true

  tags = var.tags
}

resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = var.log_destination_type == "CloudWatchLogs" ? var.log_destination_arn : null
      }
      log_destination_type = var.log_destination_type
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        logGroup = var.log_destination_type == "CloudWatchLogs" ? var.log_destination_arn : null
      }
      log_destination_type = var.log_destination_type
      log_type             = "ALERT"
    }
  }
}
