resource "google_compute_network" "vpc" {
  name                    = var.name
  project                 = var.project
  auto_create_subnetworks = false
  labels                  = var.labels
}

resource "google_compute_subnetwork" "private" {
  count         = var.num_subnets
  name          = "${var.name}-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.ip_cidr_range, 4, count.index) # Create smaller subnets from the main range
  region        = var.region
  project       = var.project
  network       = google_compute_network.vpc.id
  labels        = var.labels
}

# Cloud Router is required for Cloud NAT
resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  network = google_compute_network.vpc.id
  region  = var.region
  project = var.project
  labels  = var.labels
}

# Reserve static external IP addresses for the NAT gateway.
# This provides a stable set of egress IPs for the GKE cluster.
resource "google_compute_address" "nat" {
  count   = var.num_subnets # Typically one NAT per subnet/AZ for HA
  name    = "${var.name}-nat-ip-${count.index}"
  project = var.project
  region  = var.region
}

# Cloud NAT for outbound internet access from private subnets
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  project                            = var.project
  labels                             = var.labels
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat.*.self_link
}

# Firewall rule to allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project
  allow {
    protocol = "all"
  }
  source_ranges = [var.ip_cidr_range]
  labels        = var.labels
}

# This is required to allow managed services like Cloud SQL and Redis to connect to our private VPC.
# It reserves an IP range for Google's services.
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project
  name          = "${var.name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# This creates the private connection (VPC Peering) using the reserved range.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  # This ensures the VPC is created before attempting to peer.
  depends_on = [google_compute_network.vpc]
}
