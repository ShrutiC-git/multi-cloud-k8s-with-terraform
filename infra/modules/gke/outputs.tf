output "name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.this.name
}
