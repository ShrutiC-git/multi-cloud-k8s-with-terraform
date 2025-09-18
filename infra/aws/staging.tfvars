project_prefix = "multicloud-k8s-staging"

// VPC Settings for Staging
vpc_num_azs = 1

// EKS Cluster Settings for Staging
eks_instance_type = ["t3.micro"]
eks_desired_size  = 1
eks_max_size      = 2
eks_min_size      = 1

// RDS Database Settings for Production
rds_instance_class = "db.t3.micro"
rds_multi_az       = false
deploy_rds         = true
// You can add other RDS overrides here, like allocated_storage, etc.

// Redis Settings for Staging
redis_node_type = "cache.t3.micro"
deploy_redis = true
// The defaults for backup_retention_period and skip_final_snapshot in the module are already set for non-production.
// You would create a separate prod.tfvars in the rds module directory or override them here if needed.
