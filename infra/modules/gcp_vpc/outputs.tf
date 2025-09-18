# The static egress IP addresses allocated for the Cloud NAT gateway.
output "nat_egress_ips" {
  value = google_compute_address.nat.*.address
}
