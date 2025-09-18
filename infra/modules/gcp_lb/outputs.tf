output "ip_address" {
  description = "The static external IP address of the load balancer."
  value       = google_compute_global_address.this.address
}
