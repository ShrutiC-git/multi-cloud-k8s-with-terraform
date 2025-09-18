variable "name" {
  description = "Name for the ALB and its resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the ALB in."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB."
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the HTTPS listener."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}