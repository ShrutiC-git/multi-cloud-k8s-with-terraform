variable "name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "project" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance."
  type        = string
}

variable "network" {
  description = "The self-link of the VPC network to deploy Cloud SQL into."
  type        = string
}

variable "database_version" {
  description = "The version of the database engine."
  type        = string
  default     = "POSTGRES_13"
}

variable "tier" {
  description = "The machine type for the Cloud SQL instance. db-f1-micro is the smallest."
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "ordersdb"
}

variable "username" {
  description = "The master username for the database."
  type        = string
  default     = "demouser"
}

variable "labels" {
  description = "A map of labels to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "service_networking_connection_dependency" {
  description = "A placeholder to ensure dependency on the VPC peering connection from the VPC module."
  type        = any
}
