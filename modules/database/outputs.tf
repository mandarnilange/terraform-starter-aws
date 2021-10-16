output "main_db_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "main_db_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "db_username" {
  value = aws_rds_cluster.main.master_username
}

output "db_password" {
  value = aws_rds_cluster.main.master_password
}