variable "aws_region" {
  description = "Primary AWS region for creating backend resources (S3, DynamoDB). IMPORTANT: This must match the hardcoded 'region' in the backend blocks of the aws, gcp, and dns modules."
  type        = string
}

variable "gcp_region" {
  description = "Secondary GCP region."
  type        = string
}

variable "gcp_project" {
  description = "The GCP project ID."
  type        = string
}

variable "project_prefix" {
  description = "A short, unique prefix for all resources."
  type        = string
}

variable "dns_names" {
  description = "A map of environment names to their corresponding DNS names."
  type        = map(string)
}
