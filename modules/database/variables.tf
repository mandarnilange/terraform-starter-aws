variable "namespace" {
  type        = string
  description = "Namespace for Instance"
}

variable "db_subnet_group_id" {
  type        = string
  description = "DB Subnet Group ID"
}

variable "db_sg" {
  type        = string
  description = "DB Security group for cluster"
}