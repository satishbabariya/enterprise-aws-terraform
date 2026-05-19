provider "aws" {
  region = local.region

  default_tags {
    tags = merge(local.common_tags, {
      Account     = "management"
      Environment = "management"
    })
  }
}
