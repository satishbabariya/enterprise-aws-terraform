output "event_data_store_arn" {
  description = "CloudTrail Lake Event Data Store ARN - query via aws cloudtrail start-query"
  value       = aws_cloudtrail_event_data_store.this.arn
}

output "event_data_store_name" {
  description = "Event data store name"
  value       = aws_cloudtrail_event_data_store.this.name
}
