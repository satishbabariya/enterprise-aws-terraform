resource "aws_servicecatalog_portfolio" "this" {
  name          = "${var.org_name}-approved-blueprints"
  description   = "Approved infrastructure blueprints for self-service deployment"
  provider_name = var.portfolio_provider

  tags = var.tags
}

resource "aws_servicecatalog_principal_portfolio_association" "this" {
  for_each = toset(var.shared_with_principal_arns)

  portfolio_id  = aws_servicecatalog_portfolio.this.id
  principal_arn = each.value
}

resource "aws_servicecatalog_product" "this" {
  for_each = var.products

  name        = each.key
  owner       = each.value.owner
  description = each.value.description
  distributor = each.value.distributor
  support_email = each.value.support_email
  support_url   = each.value.support_url
  type        = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name         = "v1"
    description  = each.value.version_description
    template_url = each.value.template_url
    type         = "CLOUD_FORMATION_TEMPLATE"
  }

  tags = var.tags
}

resource "aws_servicecatalog_product_portfolio_association" "this" {
  for_each = aws_servicecatalog_product.this

  portfolio_id = aws_servicecatalog_portfolio.this.id
  product_id   = each.value.id
}
