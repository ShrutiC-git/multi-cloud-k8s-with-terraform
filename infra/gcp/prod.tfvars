gcp_project    = "multicloud-k8s-prod"

// VPC Setting
vpc_num_subnets = 3

// GKE Cluster Settings for Production
gke_instance_type = "e2-medium"
gke_max_node_count = 5
gke_min_node_count = 3

// Cloud SQL Settings for Production
sql_instance_tier = "db-n1-standard-1"

// Memorystore for Redis Settings for Production
redis_tier = "STANDARD_HA"
