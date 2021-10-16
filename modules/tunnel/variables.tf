variable "namespace" {
  type        = string
  description = "Namespace for Instance"
}

variable "tunnel_sg" {
  type        = string
  description = "Web security group"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of Public Subnet IDs"
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t3a.nano"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "key_name" {
  type        = string
  description = "Key name for EC2"
}