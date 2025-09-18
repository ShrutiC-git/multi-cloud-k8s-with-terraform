locals {
  # Use the workspace name (e.g., "staging", "prod") to ensure unique names per environment.
  env_name = terraform.workspace

  # Dynamically construct the names for the backend resources.
  # Example for 'staging': "multicloud-k8s-staging-aws-tf-state"
  aws_backend_bucket     = "${var.project_prefix}-${local.env_name}-aws-tf-state"
  aws_backend_lock_table = "${var.project_prefix}-${local.env_name}-aws-tf-locks"
  gcp_backend_bucket     = "${var.project_prefix}-${local.env_name}-gcp-tf-state"
}
