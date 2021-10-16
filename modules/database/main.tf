#TODO Hardcoded values in this module 
resource "aws_rds_cluster" "main" {
  cluster_identifier           = "${var.namespace}-main-cluster"
  engine                       = "aurora-mysql"
  engine_mode                  = "serverless"
  engine_version               = "5.7.mysql_aurora.2.07.1"
  database_name                = "fittr_db"
  master_username              = "fittr_db_admin"
  master_password              = "fittr_db123"
  backup_retention_period      = 5
  preferred_backup_window      = "03:03-05:00"
  preferred_maintenance_window = "thu:00:00-thu:03:00"
  db_subnet_group_name         = var.db_subnet_group_id
  deletion_protection          = false
  enable_http_endpoint         = true
  #   enabled_cloudwatch_logs_exports = ["error"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "snapshot"
  vpc_security_group_ids    = [var.db_sg]
  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 1
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = {
    "Name" = "${var.namespace}-MySQL-main-cluster"
  }

}