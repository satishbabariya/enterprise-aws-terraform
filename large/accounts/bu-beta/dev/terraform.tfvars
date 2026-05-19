org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "200000000006"
bu_name     = "bu-beta"
env_name    = "dev"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"

vpc_cidr              = "172.23.0.0/16"
public_subnet_cidrs   = ["172.23.0.0/24", "172.23.1.0/24", "172.23.2.0/24"]
private_subnet_cidrs  = ["172.23.10.0/24", "172.23.11.0/24", "172.23.12.0/24"]
isolated_subnet_cidrs = ["172.23.20.0/24", "172.23.21.0/24", "172.23.22.0/24"]
single_nat_gateway    = true
