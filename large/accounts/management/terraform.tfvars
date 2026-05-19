org_name              = "acme"
region                = "us-east-1"
repo_url              = "https://github.com/acme/enterprise-aws-terraform"
github_org            = "acme"
github_repo           = "enterprise-aws-terraform"
management_account_id = "111111111111"
sso_instance_arn      = "arn:aws:sso:::instance/ssoins-PLACEHOLDER"
identity_store_id     = "d-PLACEHOLDER"
allowed_regions       = ["us-east-1", "us-west-2"]

# Each account entry needs ou_key + (email to vend, OR account_id for existing).
# To vend a new account: supply `email`, leave account_id empty.
# To reference an existing account: supply `account_id`, leave email empty.
# All examples below are existing-account references; replace with `email` to vend instead.
accounts = {
  security = {
    ou_key     = "security"
    account_id = "222222222222"
  }
  log_archive = {
    ou_key     = "security"
    account_id = "444444444444"
  }
  network = {
    ou_key     = "infrastructure"
    account_id = "333333333333"
  }
  shared_services = {
    ou_key     = "infrastructure"
    account_id = "555555555555"
  }
  prod = {
    ou_key     = "workloads"
    account_id = "666666666666"
  }
  staging = {
    ou_key     = "workloads"
    account_id = "777777777777"
  }
  dev = {
    ou_key     = "workloads"
    account_id = "888888888888"
  }
  sandbox = {
    ou_key     = "workloads"
    account_id = "999999999999"
  }
}

# Example of vending instead:
# accounts = {
#   security    = { ou_key = "security",       email = "aws-security@acme.com" }
#   log_archive = { ou_key = "security",       email = "aws-logarchive@acme.com" }
#   network     = { ou_key = "infrastructure", email = "aws-network@acme.com" }
#   ...
# }

# Restrict external contractors to corporate VPN ranges. Set to [] to disable IP restriction.
external_contractor_allowed_ips = []
