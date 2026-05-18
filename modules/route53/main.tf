resource "aws_route53_zone" "private" {
  name    = var.domain_name
  comment = "Private hosted zone managed by Terraform"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = var.tags
}
