output "portfolio_id" {
  description = "Service Catalog portfolio ID"
  value       = aws_servicecatalog_portfolio.this.id
}

output "portfolio_arn" {
  description = "Service Catalog portfolio ARN"
  value       = aws_servicecatalog_portfolio.this.arn
}

output "product_ids" {
  description = "Map of product name to ID"
  value       = { for k, v in aws_servicecatalog_product.this : k => v.id }
}
