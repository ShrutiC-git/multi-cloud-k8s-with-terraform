variable "name" {
    description = "Name of the RDS instance"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the RDS instance in."
  type        = string
}

variable "subnet_ids" {
  description = "A list of private subnet IDs for the DB subnet group. Must be in at least 2 AZs for multi-az."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "A list of security group IDs that are allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The engine version to use."
  type        = string
  default     = "13.7"
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

variable "db_port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

# Production settings
variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false # Set to true for production
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 0 # Set to 7 or more for production
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true # Set to false for production
}