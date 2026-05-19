#!/usr/bin/env bash
set -euo pipefail

echo "=== Enterprise AWS Terraform Bootstrap ==="
echo ""
echo "This script creates the Terraform state S3 bucket and DynamoDB lock table"
echo "in your management account. Run this once before any other Terraform apply."
echo ""

command -v terraform >/dev/null 2>&1 || { echo "Error: terraform not found"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "Error: aws CLI not found"; exit 1; }

echo "Current AWS identity:"
aws sts get-caller-identity
echo ""
read -p "Is this your management account? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborting."; exit 1; }

cd "$(dirname "$0")/../bootstrap"

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars from example. Edit it now, then re-run this script."
  exit 0
fi

echo "Initializing with local state..."
terraform init

echo "Applying bootstrap resources..."
terraform apply

echo ""
echo "Bootstrap complete. Now migrating state to S3..."
echo "Uncomment the backend block in bootstrap/backend.tf, then run:"
echo "  cd bootstrap && terraform init -migrate-state"
