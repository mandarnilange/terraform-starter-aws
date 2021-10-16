output "alb_dns_name" {
  value = aws_alb.web.dns_name
}

output "asg_names" {
  value = aws_autoscaling_group.default.name
}