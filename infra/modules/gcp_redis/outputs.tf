output "host" {
  description = "The IP address of the Redis instance."
  value       = google_redis_instance.this.host
}

output "port" {
  description = "The port of the Redis instance."
  value       = google_redis_instance.this.port
}
