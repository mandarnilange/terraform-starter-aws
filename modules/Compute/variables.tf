variable "namespace" {
  type        = string
  description = "Namespace for Instance"
}

variable "app_name" {
  type        = string
  description = "Stack, App or Module within infra"
}

variable "private_subnet" {
  type        = string
  description = "Private subnet ID "
}

variable "web_sg" {
  type        = string
  description = "Web security group"
}

variable "vpc-id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of Public Subnet IDs"
}

variable "alb_sg" {
  type        = string
  description = "ALB security group"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t3a.nano"
}

variable "key_name" {
  type        = string
  description = "Key name for EC2"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "VPC Security Ids to be applied"
}

variable "asg_max_size" {
  type        = number
  description = "Max size for ASG "
  default     = 1
}

variable "asg_min_size" {
  type        = number
  description = "Min size for ASG "
  default     = 1
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired Capacity for ASG "
  default     = 1
}

variable "asg_default_cooldown" {
  type        = number
  description = "ASG default cooldown"
  default     = 10
}

variable "asg_launch_template_version" {
  type        = string
  description = "Lauch template version to be used for ASB"
  default     = "$Latest"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "IAM instance profile to be attached to EC2 instance"
}

variable "asg_policy_type" {
  type        = string
  description = "Target autoscaling policy type"
}

variable "asg_metric_type" {
  type        = string
  description = "Autoscaling Metric type"
}

variable "asg_metric_target_value" {
  type        = number
  description = "Metric target value for Autoscaling group"
}