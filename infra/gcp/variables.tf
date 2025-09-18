variable "gcp_project" {
    type = string
    description = "The parent GCP project where this infra will be deployed."
}

variable "gcp_region" {
    type = string
    default = "asia-south1"
}

variable "vpc_cidr" {
    description = "CIDR block for the private IPs in the VPC"
    type = string
    default = "10.1.0.0/16"
}

variable "vpc_num_subnets" {
  description = "Number of subnets to create in the VPC. Should be >= 2 for production."
  type        = number
  default     = 1
}

// GKE Cluster Settings
variable "gke_instance_type" {
  description = "Machine type for the GKE worker nodes."
  type        = string
  default     = "e2-micro"
}

variable "gke_min_node_count" {
  description = "Minimum number of GKE worker nodes."
  type        = number
  default     = 1
}

variable "gke_max_node_count" {
  description = "Maximum number of GKE worker nodes."
  type        = number
  default     = 2
}

// Cloud SQL Settings
variable "sql_instance_tier" {
  description = "Instance tier for the Cloud SQL PostgreSQL instance."
  type        = string
  default     = "db-g1-small"
}

variable "deploy_sql" {
  description = "If true, deploys the Cloud SQL PostgreSQL instance."
  type        = bool
  default     = true
}

// Memorystore for Redis Settings
variable "redis_tier" {
  description = "Tier for the Memorystore for Redis instance (BASIC or STANDARD_HA)."
  type        = string
  default     = "BASIC"
}

variable "deploy_redis" {
  description = "If true, deploys the Memorystore for Redis instance."
  type        = bool
  default     = true
}