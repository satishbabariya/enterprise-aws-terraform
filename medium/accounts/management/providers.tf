provider "aws" {
  region = local.region

  default_tags {
    tags = merge(local.common_tags, {
      Account     = "management"
      Environment = "management"
    })
  }
}

# us-east-1 alias for global services (CUR, CloudFront, IAM tokens) that must be configured there.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = merge(local.common_tags, {
      Account     = "management"
      Environment = "management"
    })
  }
}
