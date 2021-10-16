variable "namespace" {
  type        = string
  description = "Namespace for overall stack"
}

variable "profile_name" {
  type        = string
  description = "Name of Profile for AWS access"
}

variable "region" {
  type        = string
  description = "Region for Deployment"
}

variable "allowed_account_ids" {
  type        = list(string)
  description = "Allowed Account IDs for Dev Sandbox"
}

variable "default_tag_list" {
  type        = map(string)
  description = "Default tag list for all resources"
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

variable "app_stacks" {

  # Commented as experimental feature 
  # 
  # type = map(object({
  #   ami_id                      = string
  #   instance_type               = string
  #   key_name                    = string
  #   asg_max_size                = optional(number)
  #   asg_min_size                = optional(number)
  #   asg_desired_capacity        = optional(number)
  #   asg_default_cooldown        = optional(number)
  #   asg_launch_template_version = optional(string)
  # }))

  type        = map(any)
  description = "App Stack and details of app stack"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "IAM instance profile to be attached to EC2"
}