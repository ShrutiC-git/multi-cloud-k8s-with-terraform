# Create the DNS validation record for the AWS ACM certificate.
# This proves ownership of the domain to AWS Certificate Manager.
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in data.terraform_remote_state.aws.outputs.acm_certificate_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.global.outputs.hosted_zone_id
}

# Health check for primary (ALB)
resource "aws_route53_health_check" "alb_health" {
  fqdn              = data.terraform_remote_state.aws.outputs.alb_dns
  type              = "HTTPS"
  port              = 443
  resource_path     = "/healthz"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "${data.terraform_remote_state.global.outputs.dns_name}-primary-hc"
  }
}

# Look up the ALB details to get its canonical hosted zone ID
# Using the ARN is much more robust than parsing the DNS name.
data "aws_lb" "primary" {
  arn = data.terraform_remote_state.aws.outputs.alb_arn
}

# Primary failover record => alias to ALB
resource "aws_route53_record" "primary" {
  zone_id = data.terraform_remote_state.global.outputs.hosted_zone_id
  name    = data.terraform_remote_state.global.outputs.dns_name
  type    = "A"


  alias {
    name                   = data.aws_lb.primary.dns_name
    zone_id                = data.aws_lb.primary.zone_id
    evaluate_target_health = false # Not needed when a health_check_id is specified for failover routing
  }

  set_identifier = "primary"
  failover       = "PRIMARY"
  health_check_id = aws_route53_health_check.alb_health.id
}

# Health check for secondary (GCP LB)
resource "aws_route53_health_check" "gcp_health" {
  ip_address        = data.terraform_remote_state.gcp.outputs.lb_ip_address
  type              = "HTTPS"
  port              = 443
  resource_path     = "/healthz"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "${data.terraform_remote_state.global.outputs.dns_name}-secondary-hc"
  }
}

# Secondary failover record => A record to GCP LB IP
resource "aws_route53_record" "secondary" {
  zone_id = data.terraform_remote_state.global.outputs.hosted_zone_id
  name    = data.terraform_remote_state.global.outputs.dns_name
  type    = "A"
  ttl     = 60
  records = [data.terraform_remote_state.gcp.outputs.lb_ip_address]

  set_identifier = "secondary"
  failover       = "SECONDARY"
  health_check_id = aws_route53_health_check.gcp_health.id
}
