resource "aws_security_group" "this" {
  name_prefix = "${var.name}-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids # Security group of the EKS worker nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
}

# For production, a replication group provides high availability.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.name
  description                   = "Redis cluster for ${var.name}"
  node_type                     = var.node_type
  num_cache_clusters            = var.num_cache_nodes # Set to > 1 for HA
  engine                        = "redis"
  engine_version                = var.engine_version
  port                          = var.redis_port
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.this.id]
  # Production settings
  automatic_failover_enabled    = var.num_cache_nodes > 1
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
}
