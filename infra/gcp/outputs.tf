# The static IP address of the GCP Global Load Balancer.
output "lb_ip_address" {
  description = "The static IP address of the GCP Global Load Balancer."
  value       = module.gcp_lb.ip_address
}

# The static egress IP addresses allocated for the Cloud NAT gateway.
output "nat_egress_ips" {
  description = "The static egress IP addresses allocated for the Cloud NAT gateway."
  value       = module.vpc.nat_egress_ips
}
