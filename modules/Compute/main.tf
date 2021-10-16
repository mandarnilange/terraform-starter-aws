#######################################
## Luach template and Auto scaling 
#######################################

data "template_file" "test" {
  template = <<EOF
  #! /bin/bash
  echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
  EOF
}

resource "aws_launch_template" "compute" {
  name                   = "${var.namespace}-${var.app_name}-Launch-template"
  description            = "Launch Template for ${var.namespace}"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  user_data = base64encode(data.template_file.test.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.namespace}-${var.app_name}-instance"
      app  = var.app_name
    }
  }

  tags = {
    "Name" = "${var.namespace}-${var.app_name}-launch-template"
    app    = var.app_name
  }
}

resource "aws_autoscaling_group" "default" {


  name             = "${var.namespace}-${var.app_name}-ASG"
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity


  default_cooldown = 10

  health_check_type         = "ELB"
  health_check_grace_period = var.asg_default_cooldown

  vpc_zone_identifier = ["${var.private_subnet}"]


  #ALB config 
  target_group_arns = ["${aws_lb_target_group.default.arn}"]

  launch_template {
    id      = aws_launch_template.compute.id
    version = var.asg_launch_template_version
  }
  tags = [{
    "Name" = "${var.namespace}-${var.app_name}-ASG"
    app    = var.app_name
  }]
}

resource "aws_autoscaling_policy" "default" {
  name                   = "${var.namespace}-${var.app_name}-ASG-policy"
  autoscaling_group_name = aws_autoscaling_group.default.name
  # adjustment_type = ""
  policy_type = var.asg_policy_type

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.asg_metric_type
      resource_label         = ""
    }

    target_value = var.asg_metric_target_value
  }

}

# ###############################
# ## ALB and Target Group
# ################################

resource "aws_alb" "web" {
  name               = "${var.namespace}-${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.public_subnets[*]

  tags = {
    Name = "${var.namespace}--${var.app_name}-ALB"
    app  = var.app_name
  }

}

resource "aws_lb_target_group" "default" {
  name     = "${var.namespace}-${var.app_name}-tg-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id

  tags = {
    Name = "${var.namespace}-${var.app_name}-TG"
    app  = var.app_name
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  tags = {
    Name = "${var.namespace}-ALB"
  }
}
