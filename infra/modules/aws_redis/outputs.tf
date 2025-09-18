output "endpoint" { 
  description = "The primary endpoint for the Redis replication group."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}