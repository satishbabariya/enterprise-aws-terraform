# Uncomment after running: terraform init -migrate-state
#
# terraform {
#   backend "s3" {
#     bucket         = "<org_name>-<region>-tfstate"
#     key            = "bootstrap/terraform.tfstate"
#     region         = "<region>"
#     dynamodb_table = "<org_name>-<region>-tfstate-lock"
#     encrypt        = true
#   }
# }
