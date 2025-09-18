variable "name" {
  description = "Name for the GKE cluster and its resources."
  type        = string
}

variable "project" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the cluster in."
  type        = string
}

variable "network" {
  description = "The self-link of the VPC network to attach the cluster to."
  type        = string
}

variable "min_size" {
  description = "The minimum number of worker nodes."
  type        = number
}

variable "max_size" {
  description = "The maximum number of worker nodes."
  type        = number
}

variable "machine_type" {
  description = "The machine type for the GKE worker nodes."
  type        = string
}

variable "labels" {
  description = "A map of labels to assign to the resources."
  type        = map(string)
  default     = {}
}
