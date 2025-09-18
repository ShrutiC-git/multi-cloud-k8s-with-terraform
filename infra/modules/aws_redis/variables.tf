variable "name" {
  description = "The name of the Redis cluster."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the Redis cluster in."
  type        = string
}

variable "subnet_ids" { 
  description = "A list of private subnet IDs for the ElastiCache subnet group."
  type        = list(string) 
}

variable "allowed_security_group_ids" {
  description = "A list of security group IDs that are allowed to connect to the Redis cluster."
  type        = list(string)
  default     = []
}

variable "node_type" {
  description = "The instance type for the Redis nodes."
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The number of nodes in the Redis cluster. Should be >= 2 for production HA."
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "The Redis engine version."
  type        = string
  default     = "6.x"
}

variable "redis_port" {
  description = "The port for Redis."
  type        = number
  default     = 6379
}
