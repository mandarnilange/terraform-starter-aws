#########################################################
# Network creation - VPC, subnets, NACL, Security Group 
#########################################################

module "vpc" {
  source = "../modules/network"

  namespace      = var.namespace
  vpc_cidr_block = var.vpc_cidr_block

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  db_subnets      = var.db_subnets
  region          = var.region

}

#########################################################
# Compute - Create auto scaling group and ALBs at front 
#########################################################

module "compute" {
  source = "../modules/compute"

  for_each = var.app_stacks

  namespace                   = var.namespace
  app_name                    = each.key
  ami_id                      = each.value.ami_id
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  asg_max_size                = each.value.asg_max_size
  asg_min_size                = each.value.asg_min_size
  asg_desired_capacity        = each.value.asg_desired_capacity
  asg_default_cooldown        = each.value.asg_default_cooldown
  asg_launch_template_version = each.value.asg_launch_template_version
  asg_policy_type             = each.value.asg_policy_type
  asg_metric_type             = each.value.asg_metric_type
  asg_metric_target_value     = each.value.asg_metric_target_value

  iam_instance_profile_arn = var.iam_instance_profile_arn

  private_subnet = module.vpc.private_subnets[0].id
  web_sg         = module.vpc.web_sg
  vpc-id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets[*].id
  alb_sg         = module.vpc.alb_sg

  vpc_security_group_ids = ["${module.vpc.web_sg}"]

}

#########################################################
# Start/stop servers at night    
#########################################################

resource "aws_autoscaling_schedule" "dev-stop" {
  for_each = var.app_stacks

  scheduled_action_name = "dev-stop"
  min_size              = 0
  max_size              = 0
  desired_capacity      = 0
  recurrence            = "0 16 * * 1-5"
  # time_zone              = "Asia/Kolkata"
  autoscaling_group_name = module.compute[each.key].asg_names
}

resource "aws_autoscaling_schedule" "dev-start" {
  for_each = var.app_stacks

  scheduled_action_name = "dev-start"
  min_size              = 1
  max_size              = 1
  desired_capacity      = 1
  recurrence            = "30 3 * * 1-5"
  # time_zone              = "Asia/Kolkata"
  autoscaling_group_name = module.compute[each.key].asg_names
}

######################################################################
# Tunnel - Server in public subnet for accessing ssh of private EC2 
######################################################################

module "tunnel" {
  source = "../modules/tunnel"

  namespace      = var.namespace
  public_subnets = module.vpc.public_subnets[*].id
  tunnel_sg      = module.vpc.tunnel_sg
  ami_id         = "ami-0842f538dc8728b9a"
  key_name       = "sandbox-tf-mumbai"

}

#########################################################
# Database - MyAurora serverless 
#########################################################


module "database" {
  source = "../modules/database"

  namespace          = var.namespace
  db_subnet_group_id = module.vpc.db_subnet_group_id
  db_sg              = module.vpc.db_sg

  depends_on = [
    module.vpc
  ]
}

