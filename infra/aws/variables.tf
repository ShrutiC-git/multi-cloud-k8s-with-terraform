variable "aws_region" {
  description = "Primary AWS region for infra deployments"
  type        = string
  default     = "ap-south-1"
}

variable "project_prefix" {
  description = "A prefix used for naming resources, e.g., 'multicloud-k8s-prod'."
  type        = string
}

variable "vpc_cidr" {
    description = "CIDR block for the private IPs in the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_num_azs" {
  description = "Number of Availability Zones to use for the VPC. Should be >= 2 for production."
  type        = number
  default     = 1
}

// EKS Cluster Settings
variable "eks_instance_type" {
  description = "The instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.micro"]
}

variable "eks_desired_size" {
  description = "The desired number of worker nodes."
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "The maximum number of worker nodes."
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "The minimum number of worker nodes."
  type        = number
  default     = 1
}

// RDS Database Settings
variable "rds_instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "deploy_rds" {
  description = "If true, deploys the RDS PostgreSQL instance."
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "Node type for the ElastiCache for Redis cluster."
  type        = string
  default     = "cache.t3.micro"
}

variable "deploy_redis" {
  description = "If true, deploys the ElastiCache for Redis instance."
  type        = bool
  default     = false
}