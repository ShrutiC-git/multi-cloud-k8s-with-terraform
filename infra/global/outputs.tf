output "aws_backend_bucket" {
  value = aws_s3_bucket.tf_state.id
}

output "aws_backend_lock_table" {
  value = aws_dynamodb_table.tf_locks.name
}

output "gcp_backend_bucket" {
  value = google_storage_bucket.tf_state.name
}

output "dns_name" {
  description = "The DNS name for the current environment."
  value       = var.dns_names[terraform.workspace]
}

output "hosted_zone_id" {
  description = "The ID of the Route 53 Hosted Zone."
  value       = aws_route53_zone.this.id
}
