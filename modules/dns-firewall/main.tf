resource "aws_route53_resolver_firewall_domain_list" "blocked" {
  count   = length(var.blocked_domains) > 0 ? 1 : 0
  name    = "${var.org_name}-blocked-domains"
  domains = var.blocked_domains
  tags    = var.tags
}

resource "aws_route53_resolver_firewall_domain_list" "allowed" {
  count   = length(var.allowed_domains) > 0 ? 1 : 0
  name    = "${var.org_name}-allowed-domains"
  domains = var.allowed_domains
  tags    = var.tags
}

resource "aws_route53_resolver_firewall_rule_group" "this" {
  name = "${var.org_name}-dns-firewall-rules"
  tags = var.tags
}

resource "aws_route53_resolver_firewall_rule" "allow" {
  count                   = length(var.allowed_domains) > 0 ? 1 : 0
  name                    = "allow-explicit"
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.allowed[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  priority                = 10
}

resource "aws_route53_resolver_firewall_rule" "block_custom" {
  count                   = length(var.blocked_domains) > 0 ? 1 : 0
  name                    = "block-custom"
  action                  = var.block_action
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.blocked[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  priority                = 100

  block_response = var.block_action == "BLOCK" ? "NODATA" : null
}

# AWS-managed domain list IDs - look up via:
#   aws route53resolver list-firewall-domain-lists
# Common ones in us-east-1:
#   AWSManagedDomainsMalwareDomainList:       rslvr-fdl-2c46f2eced3c4abf
#   AWSManagedDomainsBotnetCommandandControl: rslvr-fdl-1bdb8b1ce4654644
#   AWSManagedDomainsAggregateThreatList:     rslvr-fdl-489d1e4d9b3949b8
resource "aws_route53_resolver_firewall_rule" "managed" {
  for_each = var.managed_domain_list_ids

  name                    = "block-${each.key}"
  action                  = var.block_action
  firewall_domain_list_id = each.value
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  priority                = 200 + index(keys(var.managed_domain_list_ids), each.key)

  block_response = var.block_action == "BLOCK" ? "NODATA" : null
}

resource "aws_route53_resolver_firewall_rule_group_association" "this" {
  for_each = toset(var.vpc_ids)

  name                   = "${var.org_name}-dns-fw-${substr(sha1(each.value), 0, 8)}"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.this.id
  vpc_id                 = each.value
  priority               = 101
  tags                   = var.tags
}
