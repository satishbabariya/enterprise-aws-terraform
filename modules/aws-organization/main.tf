resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "guardduty.amazonaws.com",
    "inspector2.amazonaws.com",
    "macie.amazonaws.com",
    "securityhub.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]
  feature_set          = "ALL"
  enabled_policy_types = var.enabled_policy_types
}

locals {
  root_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value.name
  parent_id = each.value.parent_key == "root" ? local.root_id : aws_organizations_organizational_unit.this[each.value.parent_key].id

  tags = var.tags

  depends_on = [aws_organizations_organization.this]
}
