locals {
  # Common name prefix for all resources
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags merged with additional tags
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Service     = "RDS"
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )

  # DB identifier
  db_identifier = "${local.name_prefix}-${var.db_name}"

  # Parameter group family mapping
  parameter_group_family = {
    "mysql"    = "mysql${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
    "postgres" = "postgres${split(".", var.engine_version)[0]}"
    "mariadb"  = "mariadb${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
  }

  # Resolved parameter group family
  resolved_pg_family = lookup(
    local.parameter_group_family,
    var.engine,
    "postgres${split(".", var.engine_version)[0]}"
  )

  # Port mapping by engine
  default_port = {
    "mysql"    = 3306
    "postgres" = 5432
    "mariadb"  = 3306
  }

  # Resolved DB port
  db_port = var.db_port != null ? var.db_port : lookup(local.default_port, var.engine, 5432)

  # Backup window and maintenance window
  backup_window      = var.backup_window != "" ? var.backup_window : "03:00-04:00"
  maintenance_window = var.maintenance_window != "" ? var.maintenance_window : "Mon:04:00-Mon:05:00"

  # Enhanced monitoring role name
  monitoring_role_name = "${local.name_prefix}-rds-monitoring-role"

  # CloudWatch log exports by engine
  cloudwatch_logs_exports = {
    "mysql"    = ["audit", "error", "general", "slowquery"]
    "postgres" = ["postgresql", "upgrade"]
    "mariadb"  = ["audit", "error", "general", "slowquery"]
  }

  # Resolved log exports
  resolved_log_exports = var.enabled_cloudwatch_logs_exports != null ? (
    var.enabled_cloudwatch_logs_exports
  ) : lookup(local.cloudwatch_logs_exports, var.engine, ["postgresql", "upgrade"])

  # Subnet group name
  subnet_group_name = "${local.name_prefix}-rds-subnet-group"

  # Security group name
  security_group_name = "${local.name_prefix}-rds-sg"

  # Parameter group name
  parameter_group_name = "${local.name_prefix}-rds-pg"

  # KMS key alias
  kms_key_alias = "alias/${local.name_prefix}-rds-key"

  # Multi-AZ for production
  is_production = var.environment == "prod" ? true : false

  # Final snapshot identifier
  final_snapshot_identifier = "${local.db_identifier}-final-snapshot"
}

# ==============================================================================
# Local - Resolve Monitoring Role ARN
# ==============================================================================

locals {
  monitoring_role_arn = var.monitoring_interval > 0 ? (
    var.create_monitoring_role ? (
      aws_iam_role.rds_monitoring[0].arn
    ) : var.monitoring_role_arn
  ) : null
}