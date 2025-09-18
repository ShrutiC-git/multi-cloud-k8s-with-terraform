# This resource creates the public hosted zone for the domain.
# This is a foundational resource that all other DNS records will live inside.
resource "aws_route53_zone" "this" {
  name = var.dns_names[terraform.workspace]

  tags = {
    Environment = terraform.workspace
    Project     = var.project_prefix
  }
}
