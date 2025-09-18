# GKE Cluster (Control Plane)
resource "google_container_cluster" "this" {
  name     = var.name
  location = var.region
  project  = var.project

  # We can't create a cluster with no node pool defined, but we want to manage
  # it as a separate resource for more flexibility.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  resource_labels = var.labels
}

# GKE Node Pool (Worker Nodes)
resource "google_container_node_pool" "primary" {
  name       = "${var.name}-node-pool"
  location   = var.region
  project    = var.project
  cluster    = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.min_size
    max_node_count = var.max_size
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = var.labels
  }
}
