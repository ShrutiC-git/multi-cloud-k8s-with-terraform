resource "google_redis_instance" "this" {
  name           = var.name
  project        = var.project
  tier           = var.tier
  memory_size_gb = 1

  location_id = "${var.region}-a" # Memorystore is zonal, so we pick the first zone in the region
  region      = var.region

  connect_mode = "PRIVATE_SERVICE_ACCESS"
  network      = var.network

  # This ensures the VPC peering from the Cloud SQL module is ready.
  # In a larger project, this peering would be in the VPC module itself.
  depends_on = [
    var.service_networking_connection
  ]
  labels = var.labels
}
