output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "web_sg" {
  value = aws_security_group.web_sg.id
}

output "db_sg" {
  value = aws_security_group.db_sg.id
}

output "tunnel_sg" {
  value = aws_security_group.tunnel_sg.id
}

output "public_subnets" {
  value = aws_subnet.public[*]
}

output "private_subnets" {
  value = aws_subnet.private[*]
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.default.id
}
