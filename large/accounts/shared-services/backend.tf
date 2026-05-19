terraform {
  backend "s3" {
    bucket         = "acme-us-east-1-tfstate"
    key            = "large/shared-services/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-us-east-1-tfstate-lock"
    encrypt        = true
  }
}
