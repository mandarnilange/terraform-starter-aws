variable "namespace" {
  type        = string
  description = "Namespace for Instance"
}
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR Block to be applied to VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of Private Subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of Public Subnets"
}

variable "db_subnets" {
  type        = list(string)
  description = "List of Private Subnets"
}

variable "region" {
  type        = string
  description = "region"
}

