output "vpc-id" {
  value = module.vpc.vpc_id
}

output "tunnel_server" {
  value = module.tunnel.tunnel_server
}

output "alb_dns_name" {

  value = { for k, v in module.compute : k => v.alb_dns_name }
}

output "alb_sg" {
  value = module.vpc.alb_sg
}

output "web_sg" {
  value = module.vpc.web_sg
}

output "db_sg" {
  value = module.vpc.db_sg
}

output "private_subnets" {
  value = module.vpc.private_subnets[*].cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets[*].cidr_block
}

output "db_subnet_group_id" {
  value = module.vpc.db_subnet_group_id
}

output "db_details" {
  value = {
    db_endpoint        = "${module.database.main_db_endpoint}",
    db_reader_endpoint = "${module.database.main_db_reader_endpoint}",
    db_username        = "${module.database.db_username}",
  }

}


