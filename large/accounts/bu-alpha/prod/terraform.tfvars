org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "200000000001"
bu_name     = "bu-alpha"
env_name    = "prod"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"

vpc_cidr              = "172.18.0.0/16"
public_subnet_cidrs   = ["172.18.0.0/24", "172.18.1.0/24", "172.18.2.0/24"]
private_subnet_cidrs  = ["172.18.10.0/24", "172.18.11.0/24", "172.18.12.0/24"]
isolated_subnet_cidrs = ["172.18.20.0/24", "172.18.21.0/24", "172.18.22.0/24"]
single_nat_gateway    = false
