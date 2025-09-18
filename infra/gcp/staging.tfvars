gcp_project    = "multicloud-k8s-staging"

// VPC Setting
vpc_num_subnets = 1

// GKE Cluster Settings for Staging
gke_instance_type = "e2-micro"
gke_max_node_count = 2
gke_min_node_count = 1

// Cloud SQL Settings for Staging
sql_instance_tier = "db-g1-small"

// Memorystore for Redis Settings for Staging
redis_tier = "BASIC"
