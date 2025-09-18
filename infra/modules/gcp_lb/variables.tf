variable "name" {
  description = "Name for the Load Balancer and its resources."
  type        = string
}

variable "project" {
  description = "The GCP project ID."
  type        = string
}

variable "dns_name" {
  description = "The domain name for which to create the SSL certificate."
  type        = string
}

variable "labels" {
  description = "A map of labels to assign to the resources."
  type        = map(string)
  default     = {}
}
