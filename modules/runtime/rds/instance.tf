# ==============================================================================
# Random Password Generation
# ==============================================================================

resource "random_password" "db_password" {
  count = var.db_password == "" ? 1 : 0

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# ==============================================================================
# Store Password in AWS Secrets Manager
# ==============================================================================

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.db_identifier}-db-password"
  description             = "Master password for RDS instance ${local.db_identifier}"
  kms_key_id              = local.kms_key_id
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "${local.db_identifier}-db-password"
    Purpose = "RDS Master Password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
    host     = aws_db_instance.rds.address
    port     = aws_db_instance.rds.port
    dbname   = var.db_name
    engine   = var.engine
  })

  depends_on = [aws_db_instance.rds]
}

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

  # Authentication
  username = var.db_username
  password = var.db_password != "" ? var.db_password : random_password.db_password[0].result

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
  performance_insights_retention_period = var.performance_insights_enabled ? (
    var.performance_insights_retention_period
  ) : null
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

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}