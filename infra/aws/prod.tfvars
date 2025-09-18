project_prefix = "multicloud-k8s-prod"

// VPC Settings for Production
vpc_num_azs = 3

// EKS Cluster Settings for Production
eks_instance_type = ["t3.medium"]
eks_desired_size  = 3
eks_max_size      = 5
eks_min_size      = 2

// RDS Database Settings for Production
rds_instance_class = "db.t3.small"
rds_multi_az       = true
deploy_rds         = true
// You can add other RDS overrides here, like allocated_storage, etc.

// Redis Settings for Production
redis_node_type = "cache.t3.small"
deploy_redis    = true
// The defaults for backup_retention_period and skip_final_snapshot in the module are already set for non-production.
// You would create a separate prod.tfvars in the rds module directory or override them here if needed.
