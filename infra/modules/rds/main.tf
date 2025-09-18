resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}-db-creds"
  tags = merge(var.tags, {
    Name = "${var.name}-db-creds"
  })
} # New container to hold the DB creds

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.password.result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
} # For storing the DB username and password together so other apps can access.

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Controls access to the RDS instance"
  vpc_id      = var.vpc_id

  # Allow traffic only from the specified security groups (e.g., EKS nodes).
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_db_subnet_group" "this" {
  name = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier           = var.name
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  username             = var.username
  password             = random_password.password.result
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  # Production settings
  multi_az               = var.multi_az
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot    = var.skip_final_snapshot
  tags                   = merge(var.tags, {
    Name = var.name
  })
}