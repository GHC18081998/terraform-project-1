# ==============================================================================
# RDS Instance
# ==============================================================================

resource "aws_db_instance" "rds" {
  # Identification
  identifier = local.db_identifier
  db_name    = var.db_name

  # Engine Configuration
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  iops                  = contains(["io1", "io2"], var.storage_type) ? var.iops : null
  storage_throughput    = var.storage_type == "gp3" ? var.storage_throughput : null

  # -------------------------------------------------------------
  # Authentication (Native AWS Secrets Manager Integration)
  # -------------------------------------------------------------
  username                      = var.db_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = local.kms_key_id

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  port                   = local.db_port
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  # Encryption
  storage_encrypted = var.storage_encrypted
  kms_key_id        = local.kms_key_id

  # Parameter & Option Groups
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.rds[0].name : null
  option_group_name    = var.create_option_group && contains(["mysql", "mariadb"], var.engine) ? aws_db_option_group.rds[0].name : null

  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = local.backup_window
  maintenance_window        = local.maintenance_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : local.final_snapshot_identifier

  # Monitoring
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = local.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? local.kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  enabled_cloudwatch_logs_exports       = local.resolved_log_exports

  # Upgrade Configuration
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  # Deletion Protection
  deletion_protection = var.deletion_protection

  tags = merge(local.common_tags, {
    Name    = local.db_identifier
    Purpose = "RDS Database Instance"
  })

  depends_on = [
    aws_db_subnet_group.rds,
    aws_security_group.rds,
    aws_db_parameter_group.rds,
    aws_iam_role_policy_attachment.rds_monitoring
  ]
  
  # Note: The lifecycle { ignore_changes = [password] } block is removed 
  # because Terraform is no longer managing the password argument.
}
