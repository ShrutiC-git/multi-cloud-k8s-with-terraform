variable "name" {
  description = "The name of the Redis instance."
  type        = string
}

variable "project" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the Redis instance."
  type        = string
}

variable "network" {
  description = "The self-link of the VPC network to deploy Redis into."
  type        = string
}

variable "tier" {
  description = "The service tier of the instance. BASIC is for a standalone instance."
  type        = string
  default     = "BASIC"
}

variable "service_networking_connection" {
  description = "A placeholder to ensure dependency on the VPC peering connection."
  type        = any
}

variable "labels" {
  description = "A map of labels to assign to the resources."
  type        = map(string)
  default     = {}
}
