locals {
  tag_policy = {
    tags = {
      Environment = {
        tag_key = { "@@assign" = "Environment" }
        tag_value = {
          "@@assign" = var.valid_environments
        }
        enforced_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      DataClass = {
        tag_key = { "@@assign" = "DataClass" }
        tag_value = {
          "@@assign" = var.valid_data_classifications
        }
        enforced_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      ComplianceScope = {
        tag_key = { "@@assign" = "ComplianceScope" }
        tag_value = {
          "@@assign" = var.valid_compliance_scopes
        }
        enforced_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      CostCenter = {
        tag_key = { "@@assign" = "CostCenter" }
        enforced_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      Organization = {
        tag_key = { "@@assign" = "Organization" }
      }
      ManagedBy = {
        tag_key = { "@@assign" = "ManagedBy" }
      }
    }
  }
}

resource "aws_organizations_policy" "required_tags" {
  name        = "RequiredTagsPolicy"
  description = "Enforces Environment, DataClass, ComplianceScope, CostCenter tags on critical resources"
  type        = "TAG_POLICY"
  content     = jsonencode(local.tag_policy)
  tags        = var.tags
}
