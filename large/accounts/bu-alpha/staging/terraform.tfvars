org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "200000000002"
bu_name     = "bu-alpha"
env_name    = "staging"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"

vpc_cidr              = "172.19.0.0/16"
public_subnet_cidrs   = ["172.19.0.0/24", "172.19.1.0/24", "172.19.2.0/24"]
private_subnet_cidrs  = ["172.19.10.0/24", "172.19.11.0/24", "172.19.12.0/24"]
isolated_subnet_cidrs = ["172.19.20.0/24", "172.19.21.0/24", "172.19.22.0/24"]
single_nat_gateway    = true
