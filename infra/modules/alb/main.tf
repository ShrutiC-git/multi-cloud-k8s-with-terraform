resource "aws_security_group" "this" {
  name_prefix = "${var.name}-sg"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    # For production, consider restricting this to known IPs (e.g., a WAF or CDN) if applicable.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    # For production, consider restricting this to known IPs (e.g., a WAF or CDN) if applicable.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.this.id]
  tags = merge(var.tags, {
    Name = var.name
  })
}

# Default target group for the ALB. The AWS Load Balancer Controller
# will create its own target groups for K8s services.
resource "aws_lb_target_group" "default" {
  name     = "${var.name}-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  tags = merge(var.tags, {
    Name = "${var.name}-default-tg"
  })
}

# Listener for HTTP on port 80 that redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener for HTTPS on port 443
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}