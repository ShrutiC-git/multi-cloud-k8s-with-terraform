output "failover_record" {
  description = "The FQDN of the Route 53 record with failover."
  value = aws_route53_record.primary.fqdn
}

output "primary_endpoint_dns" {
  description = "The DNS name of the primary (AWS ALB) endpoint."
  value       = data.terraform_remote_state.aws.outputs.alb_dns
}

output "secondary_endpoint_ip" {
  description = "The IP address of the secondary (GCP LB) endpoint."
  value       = data.terraform_remote_state.gcp.outputs.lb_ip_address
}
