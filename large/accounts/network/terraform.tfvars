org_name           = "acme"
region             = "us-east-1"
repo_url           = "https://github.com/acme/enterprise-aws-terraform"
network_account_id = "333333333333"

# Large deployment uses 172.16/12 space to avoid medium-deployment conflicts
vpc_cidr              = "172.16.0.0/16"
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs   = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
private_subnet_cidrs  = ["172.16.10.0/24", "172.16.11.0/24", "172.16.12.0/24"]
isolated_subnet_cidrs = ["172.16.20.0/24", "172.16.21.0/24", "172.16.22.0/24"]
