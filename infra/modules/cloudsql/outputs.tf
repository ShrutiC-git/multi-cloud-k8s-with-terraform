output "connection_name" {
  description = "The connection name of the Cloud SQL instance, used by the Cloud SQL Auth Proxy."
  value       = google_sql_database_instance.this.connection_name
}

output "db_credentials_secret_id" {
  description = "The ID of the secret containing the database credentials."
  value       = google_secret_manager_secret.this.secret_id
}

output "service_networking_connection" {
  description = "The service networking connection resource for dependency chaining."
  value       = google_service_networking_connection.private_vpc_connection
}
