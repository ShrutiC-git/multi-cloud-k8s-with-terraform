output "acm_certificate_validation_options" {
  description = "The validation options for the ACM certificate, used by the DNS module."
  value       = aws_acm_certificate.this.domain_validation_options
}

output "alb_dns" {
  description = "The DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer."
  value       = module.alb.zone_id
}
