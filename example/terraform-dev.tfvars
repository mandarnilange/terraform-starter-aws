namespace                = "sandbx"
profile_name             = "tf-user"
region                   = "ap-south-1"
allowed_account_ids      = ["469786730377"]
default_tag_list         = { namespace = "sandbx", env = "dev" }
vpc_cidr_block           = "10.0.0.0/16"
private_subnets          = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
public_subnets           = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
db_subnets               = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
iam_instance_profile_arn = "arn:aws:iam::469786730377:instance-profile/sandbox_ec2_role"
app_stacks = {
  My-API = {
    ami_id                      = "ami-0842f538dc8728b9a"
    instance_type               = "t3a.nano"
    key_name                    = "sandbox-tf-mumbai"
    asg_max_size                = 1
    asg_min_size                = 1
    asg_desired_capacity        = 1
    asg_default_cooldown        = 10
    asg_launch_template_version = "$Latest"
    asg_policy_type             = "TargetTrackingScaling"
    asg_metric_type             = "ASGAverageCPUUtilization"
    asg_metric_target_value     = 40.0
  },
  My-Web = {
    ami_id                      = "ami-03bd27b800f70b70c"
    instance_type               = "t3a.nano"
    key_name                    = "sandbox-tf-mumbai"
    asg_max_size                = 1
    asg_min_size                = 1
    asg_desired_capacity        = 1
    asg_default_cooldown        = 10
    asg_launch_template_version = "$Latest"
    asg_policy_type             = "TargetTrackingScaling"
    asg_metric_type             = "ASGAverageCPUUtilization"
    asg_metric_target_value     = 40.0
  }
}
