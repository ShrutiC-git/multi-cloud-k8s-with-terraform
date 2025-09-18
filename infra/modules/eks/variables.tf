variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the cluster in."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch the cluster in."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "The desired Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.28"
}

variable "instance_type" {
  description = "The instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.micro"]
}

variable "desired_size" {
  description = "The desired number of worker nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of worker nodes."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
