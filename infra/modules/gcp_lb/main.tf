# Reserve a static external IP address for the GCP load balancer. By default, the address is an external IP address.
# This is the critical component for DNS failover.
resource "google_compute_global_address" "this" {
  name    = "${var.name}-ip"
  project = var.project
  labels  = var.labels
}

# A default backend service. This acts as a placeholder.
# The GKE Ingress controller will create and manage its own backends.
resource "google_compute_backend_service" "placeholder" {
  name        = "${var.name}-default-backend"
  project     = var.project
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10
  labels      = var.labels
}

# A default URL map to route all traffic to the default backend.
resource "google_compute_url_map" "placeholder" {
  name            = "${var.name}-url-map"
  project         = var.project
  default_service = google_compute_backend_service.placeholder.id
  labels          = var.labels
}

# A Google-managed SSL certificate for the domain.
resource "google_compute_managed_ssl_certificate" "this" {
  name    = "${var.name}-ssl-cert"
  project = var.project
  managed {
    domains = [var.dns_name]
  }
  labels = var.labels
}

# An HTTPS proxy to route requests to the URL map.
resource "google_compute_target_https_proxy" "https" {
  name             = "${var.name}-https-proxy"
  project = var.project
  url_map = google_compute_url_map.placeholder.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.this.self_link]
  labels           = var.labels
}

# The global forwarding rule that connects the static IP to the proxy.
# This is the entrypoint for all HTTPS traffic.
resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.name}-https-forwarding-rule"
  project    = var.project
  target     = google_compute_target_https_proxy.https.self_link
  port_range = "443"
  ip_address = google_compute_global_address.this.address
  labels     = var.labels
}

# Note: You will also need to add a `dns_name` variable to this module's `variables.tf`
# and pass it in from the root `gcp` configuration.
