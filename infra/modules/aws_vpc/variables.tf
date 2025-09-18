variable "name" {
  description = "Name for the VPC and its resources."
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "num_azs" {
  description = "Number of Availability Zones to use."
  type        = number
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
