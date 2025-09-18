resource "google_storage_bucket" "tf_state" {
  name          = local.gcp_backend_bucket
  location      = var.gcp_region
  force_destroy = true

  versioning {
    enabled = true
  }
}
