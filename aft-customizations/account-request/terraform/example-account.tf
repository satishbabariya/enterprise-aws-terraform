################################################################################
# Example account request.
#
# This file goes in your `aft-account-request` repo. Committing it triggers
# AFT to provision the account via Control Tower's Account Factory, then
# run global-customizations + the matching account-customizations.
#
# One module call per account. Lift this pattern for every new account.
################################################################################

module "checkout_prod" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "aws-checkout-prod@acme.com"
    AccountName               = "checkout-prod"
    ManagedOrganizationalUnit = "Workloads"
    SSOUserEmail              = "platform-ops@acme.com"
    SSOUserFirstName          = "Platform"
    SSOUserLastName           = "Operations"
  }

  account_tags = {
    Organization    = "acme"
    BusinessUnit    = "checkout"
    Environment     = "prod"
    DataClass       = "confidential"
    ComplianceScope = "pci"
    CostCenter      = "engineering"
    ManagedBy       = "aft"
  }

  change_management_parameters = {
    change_requested_by = "@satishbabariya"
    change_reason       = "Spin up dedicated prod account for checkout BU per ADR-0042"
  }

  custom_fields = {
    # Drives which account-customization runs after the global one.
    account_type = "workload-prod"
  }

  account_customizations_name = "workload-prod"
}

module "data_analytics_dev" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "aws-analytics-dev@acme.com"
    AccountName               = "data-analytics-dev"
    ManagedOrganizationalUnit = "Workloads"
    SSOUserEmail              = "platform-ops@acme.com"
    SSOUserFirstName          = "Platform"
    SSOUserLastName           = "Operations"
  }

  account_tags = {
    Organization    = "acme"
    BusinessUnit    = "data"
    Environment     = "dev"
    DataClass       = "internal"
    ComplianceScope = "soc2"
    CostCenter      = "data-platform"
    ManagedBy       = "aft"
  }

  change_management_parameters = {
    change_requested_by = "@satishbabariya"
    change_reason       = "Dev account for data team Q3 experimentation"
  }

  custom_fields = {
    account_type = "workload-non-prod"
  }

  account_customizations_name = "workload-non-prod"
}
