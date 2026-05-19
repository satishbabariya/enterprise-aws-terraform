#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -s <medium|large> -n <account-name> -e <environment> -i <aws-account-id> [-c <cidr>]"
  echo ""
  echo "  -s  Scale: medium or large"
  echo "  -n  Account name (lowercase, hyphens ok). Example: prod, bu-alpha-prod"
  echo "  -e  Environment: prod, staging, dev, sandbox, management"
  echo "  -i  AWS account ID (12 digits)"
  echo "  -c  VPC CIDR block. Example: 10.5.0.0/16"
  exit 1
}

while getopts "s:n:e:i:c:" opt; do
  case $opt in
    s) SCALE="$OPTARG" ;;
    n) ACCOUNT_NAME="$OPTARG" ;;
    e) ENVIRONMENT="$OPTARG" ;;
    i) ACCOUNT_ID="$OPTARG" ;;
    c) VPC_CIDR="$OPTARG" ;;
    *) usage ;;
  esac
done

[[ -z "${SCALE:-}" || -z "${ACCOUNT_NAME:-}" || -z "${ENVIRONMENT:-}" || -z "${ACCOUNT_ID:-}" ]] && usage

DIR="${SCALE}/accounts/${ACCOUNT_NAME}"

if [ -d "$DIR" ]; then
  echo "Error: $DIR already exists"
  exit 1
fi

echo "Scaffolding $DIR..."
mkdir -p "$DIR"

cat > "$DIR/versions.tf" << 'EOF'
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
EOF

PREFIX=""
[[ "$SCALE" == "large" ]] && PREFIX="large/"
cat > "$DIR/backend.tf" << EOF
terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "${PREFIX}${ACCOUNT_NAME}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
EOF

cat > "$DIR/terraform.tfvars" << EOF
org_name    = "acme"
region      = "us-east-1"
repo_url    = "https://github.com/acme/enterprise-aws-terraform"
account_id  = "${ACCOUNT_ID}"
github_org  = "acme"
github_repo = "enterprise-aws-terraform"
vpc_cidr    = "${VPC_CIDR:-10.0.0.0/16}"
EOF

cat > "$DIR/main.tf" << EOF
# ${ACCOUNT_NAME} account - ${ENVIRONMENT} environment
# Scaffolded by scripts/new-account.sh
# Add module calls here following the pattern in ${SCALE}/accounts/prod/main.tf
EOF

touch "$DIR/outputs.tf"
cp medium/accounts/prod/variables.tf "$DIR/variables.tf"

echo "Created $DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $DIR/terraform.tfvars with real values"
echo "  2. Add module calls to $DIR/main.tf"
echo "  3. Run: cd $DIR && terraform init && terraform validate"
