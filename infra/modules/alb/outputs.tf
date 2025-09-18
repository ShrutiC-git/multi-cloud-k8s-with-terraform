output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.alb.dns_name
}

output "arn" {
  description = "The ARN of the load balancer."
  value       = aws_lb.alb.arn
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.alb.zone_id
}