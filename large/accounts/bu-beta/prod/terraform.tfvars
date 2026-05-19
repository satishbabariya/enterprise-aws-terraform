org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "200000000004"
bu_name     = "bu-beta"
env_name    = "prod"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"

vpc_cidr              = "172.21.0.0/16"
public_subnet_cidrs   = ["172.21.0.0/24",  "172.21.1.0/24",  "172.21.2.0/24"]
private_subnet_cidrs  = ["172.21.10.0/24", "172.21.11.0/24", "172.21.12.0/24"]
isolated_subnet_cidrs = ["172.21.20.0/24", "172.21.21.0/24", "172.21.22.0/24"]
single_nat_gateway    = false
