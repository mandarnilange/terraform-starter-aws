# Terraform Starter for AWS 

Starter terraform for generating three tier infrastrastructure on AWS. 

## Background

This is starter project build for setting up multi-tier environment using terraform. <br/>


## Required before you start 
Installed version of terraform 1.0 <br/>
EC2 Key pair created in AWS  <br/>
Instance profile created for EC2 <br/>


## Modules  
Following are the key modules created as part of this repo. 

### network module 
Network module creates VPC, NACL rules, security groups and vpc endpoints ssm and S3 access for the EC2 instances 

Example 

```
module "vpc" {
  source = "../modules/network"

  namespace      = var.namespace
  vpc_cidr_block = var.vpc_cidr_block

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  db_subnets      = var.db_subnets
  region          = var.region

}
```

### Compute module 
Compute module creates auto scaling group, EC2 instances from AMI and ALB in front of ASB

```
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
```

### database module 
Database module is current hardcoded to start MySQL DB on Aurora Serverless. 

```
module "database" {
  source = "../modules/database"

  namespace          = var.namespace
  db_subnet_group_id = module.vpc.db_subnet_group_id
  db_sg              = module.vpc.db_sg

  depends_on = [
    module.vpc
  ]
}
```

## Architecture example 

![Sample AWS Architecture](/AWS example architecture.png)

## Steps to use example 

### Update terraform variables
Update terraform variables in /example/terraform-dev.tfvars to reflect your needed environment 

| Variable Name | Description of the variable | 
| ------------- | --------------------------- | 
| namespace | Name of the environment or namespace to be used to uniquely identify network | 
| profile_name | AWS profile name to be used to execute terraform command. Create profile using AWS CLI config | 
| region | Region in which environment needs to be created | 
| allowed_account_ids | AWS Account ID in which environment to be created. ***Key to protect that wrong account is not used***| 
| default_tag_list | Default tags to be attached to all resources created | 
| vpc_cidr_block | CIDR block for VPC to be created | 
| private_subnets| List of private subnets to be created | 
| public_subnets | List of public subnets to be created | 
| db_subnets | List of subnets to be used for database | 
| app_stacks | json format detailing end to end stack using ALBs / EC2 | 



### Initiallize Terraform 
Change to /exmaples directory and execute following command to initialize terraform 

```
terraform init 
```

### Check Terraform execution plan 
Execute following command to check the execution plan for the terraform 

```
terraform plan -var-file=terraform-dev.tfvars 
```

### Apply Terraform execution plan 
Execute following command to create the infrastructure  

```
terraform apply -var-file=terraform-dev.tfvars 
```

### Check deployed environment 
Terraform will output following details post execution. If your AMI has apache installed then use the endpoints listed in the alb_dns_name output 

```
  + alb_dns_name       = {
      + My-API = (known after apply)
      + My-Web = (known after apply)
    }
  + alb_sg             = (known after apply)
  + db_details         = {
      + db_endpoint        = (known after apply)
      + db_reader_endpoint = (known after apply)
      + db_username        = "fittr_db_admin"
    }
  + db_sg              = (known after apply)
  + db_subnet_group_id = (known after apply)
  + private_subnets    = [
      + "10.0.48.0/20",
      + "10.0.64.0/20",
      + "10.0.80.0/20",
    ]
  + public_subnets     = [
      + "10.0.0.0/20",
      + "10.0.16.0/20",
      + "10.0.32.0/20",
    ]
  + tunnel_server      = (known after apply)
  + vpc-id             = (known after apply)
  + web_sg             = (known after apply)
```

### Some additional functionalities in example 
Example implements swtiching off all instances at night time IST 
```
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
```

Tunnel server is setup in public subnet to access private EC2 instance (SSM is enabled by default but added as example)

```
module "tunnel" {
  source = "../modules/tunnel"

  namespace      = var.namespace
  public_subnets = module.vpc.public_subnets[*].id
  tunnel_sg      = module.vpc.tunnel_sg
  ami_id         = "ami-0842f538dc8728b9a"
  key_name       = "sandbox-tf-mumbai"

}
```

### Destroy all artefacts created 
Once you are done with execution, destroy environment using following command 

```
terraform destroy -var-file=terraform-dev.tfvars 
```

## Author

[Mandar Nilange](https://www.mandarnilange.com) <br/><br/>



