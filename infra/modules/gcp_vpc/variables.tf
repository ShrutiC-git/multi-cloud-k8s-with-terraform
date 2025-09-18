variable "name" {
  description = "The name of the VPC network."
  type        = string
}

variable "project" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the VPC and subnets in."
  type        = string
}

variable "ip_cidr_range" {
  description = "The IP address range of the subnetwork."
  type        = string
}

variable "num_subnets" {
  description = "Number of subnets to create."
  type        = number
  default     = 1
}

variable "labels" {
  description = "A map of labels to assign to the resources."
  type        = map(string)
  default     = {}
}
