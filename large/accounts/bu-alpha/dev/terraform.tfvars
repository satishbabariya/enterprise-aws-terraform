org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "200000000003"
bu_name     = "bu-alpha"
env_name    = "dev"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"

vpc_cidr              = "172.20.0.0/16"
public_subnet_cidrs   = ["172.20.0.0/24",  "172.20.1.0/24",  "172.20.2.0/24"]
private_subnet_cidrs  = ["172.20.10.0/24", "172.20.11.0/24", "172.20.12.0/24"]
isolated_subnet_cidrs = ["172.20.20.0/24", "172.20.21.0/24", "172.20.22.0/24"]
single_nat_gateway    = true
