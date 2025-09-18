# Data sources to look up the ARN for AWS-managed IAM policies.
data "aws_iam_policy" "cluster_policy" {
  name = "AmazonEKSClusterPolicy"
} # Grants the EKS Control Plane permissions to manage AWS resources.

data "aws_iam_policy" "worker_node_policy" {
  name = "AmazonEKSWorkerNodePolicy"
} # Core policies for the worker nodes to connect to the control plane.

data "aws_iam_policy" "cni_policy" {
  name = "AmazonEKS_CNI_Policy"
} # Allows the network plugins on the nodes to manage IP addresses within VPC.

data "aws_iam_policy" "ecr_read_only_policy" {
  name = "AmazonEC2ContainerRegistryReadOnly"
} # Allows worker nodes to pull container images from Amazon ECR.

# IAM role for the EKS cluster control plane
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-role"
  })
}

# Attaching the cluster AWS policy to the cluster role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = data.aws_iam_policy.cluster_policy.arn
  role       = aws_iam_role.cluster.name
}

# IAM role for the EKS worker nodes
resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-role"
  })
}

# Attaching the necessary policies to the worker node role

resource "aws_iam_role_policy_attachment" "nodes_worker_policy" {
  policy_arn = data.aws_iam_policy.worker_node_policy.arn
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_cni_policy" {
  policy_arn = data.aws_iam_policy.cni_policy.arn
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ecr_policy" {
  policy_arn = data.aws_iam_policy.ecr_read_only_policy.arn
  role       = aws_iam_role.nodes.name
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# Security Group for the EKS worker nodes.
# This allows us to reference it from other security groups (like RDS).
resource "aws_security_group" "node_group" {
  name_prefix = "${var.cluster_name}-node-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-sg"
  })
}

# EKS Node Group to provision the worker nodes
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.subnet_ids

  # Associate the node group with our explicitly created security group.
  # This replaces the default security group EKS would have created.
  vpc_security_group_ids = [aws_security_group.node_group.id]

  instance_types = var.instance_types
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # This ensures the node group is created only after the cluster is up
  # and all necessary IAM policies are attached to the node role.
  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker_policy,
    aws_iam_role_policy_attachment.nodes_cni_policy,
    aws_iam_role_policy_attachment.nodes_ecr_policy,
  ]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ng"
  })
}
