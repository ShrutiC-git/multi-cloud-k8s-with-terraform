locals {
    name_prefix = "${var.project_prefix}-aws"
}

module "vpc" {
    source = "../modules/aws_vpc"
    name = local.name_prefix
    cidr = var.vpc_cidr
    num_azs = var.vpc_num_azs
    tags    = { "Project" = var.project_prefix }
}

module "eks" {
    source = "../modules/eks"
    cluster_name = local.name_prefix
    vpc_id = module.vpc.vpc_id
    subnet_ids   = module.vpc.private_subnet_ids
    instance_type = var.eks_instance_type
    desired_size  = var.eks_desired_size
    max_size      = var.eks_max_size
    min_size      = var.eks_min_size
    tags          = { "Project" = var.project_prefix }
}

module "rds" {
  # Minimal setup, default to "deploy with RDS"
  count  = var.deploy_rds ? 1 : 0 # change the '1' for HA
  source = "../modules/rds"
  name   = "${local.name_prefix}-rds"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids # IDs of the private subnets from the VPC module.
  instance_class = var.rds_instance_class
  tags          = { "Project" = var.project_prefix }
  allowed_security_group_ids = [module.eks.node_security_group_id]
}

module "redis" {
  # Minimal setup, default to "deploy without Redis"
  count  = var.deploy_redis ? 1 : 0 # Change the '1' for HA
  source = "../modules/aws_redis"
  name   = "${local.name_prefix}-redis"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_type  = var.redis_node_type
  tags       = { "Project" = var.project_prefix }
  # Same dependency logic as the RDS module.
  allowed_security_group_ids = [module.eks.node_security_group_id]
}

resource "aws_acm_certificate" "this" {
  domain_name       = data.terraform_remote_state.global.outputs.dns_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = var.project_prefix
    Name    = "${local.name_prefix}-cert"
  }
}

module "alb" {
  source = "../modules/alb"
  name = "${local.name_prefix}-alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = aws_acm_certificate.this.arn
  tags              = { "Project" = var.project_prefix }
}