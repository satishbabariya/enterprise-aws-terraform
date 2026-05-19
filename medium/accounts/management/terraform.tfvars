org_name              = "acme"
region                = "us-east-1"
repo_url              = "https://github.com/acme/enterprise-aws-terraform"
github_org            = "acme"
github_repo           = "enterprise-aws-terraform"
management_account_id = "111111111111"
sso_instance_arn      = "arn:aws:sso:::instance/ssoins-PLACEHOLDER"
identity_store_id     = "d-PLACEHOLDER"
allowed_regions       = ["us-east-1", "us-west-2"]

account_ids = {
  security        = "222222222222"
  log_archive     = "444444444444"
  network         = "333333333333"
  shared_services = "555555555555"
  prod            = "666666666666"
  staging         = "777777777777"
  dev             = "888888888888"
  sandbox         = "999999999999"
}

# Restrict external contractors to corporate VPN ranges. Set to [] to disable IP restriction.
external_contractor_allowed_ips = []
