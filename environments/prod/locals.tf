# ==============================================================
# Environment Locals & Shared Expressions
# ==============================================================
# Location: environments/prod/locals.tf

locals {
  # Base tags applied to everything in this environment
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }

  # The ultimate tag map to pass to your modules.
  # Merges common tags, extra variables, and production compliance tags.
  environment_tags = merge(
    local.common_tags,
    var.extra_tags,
    {
      Compliance = "Production"
    }
  )

  # Production-specific RDS configuration overrides (Hardened for Reliability)
  multi_az            = true    # High availability enabled for production
  deletion_protection = true    # Prevent accidental database deletion
  skip_final_snapshot = false   # Ensure final snapshot is taken on destroy

  # Performance Insights retention (extended for production troubleshooting)
  performance_insights_retention_period = 7

  # Production backup retention (passed from variable or defaulted)
  backup_retention_period = var.backup_retention_period

  # Production-specific parameters for PostgreSQL auditing and slow-query logging
  postgres_parameters = [
    {
      name         = "log_connections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_disconnections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_duration"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_min_duration_statement"
      value        = "1000" # Logs queries taking longer than 1 second
      apply_method = "immediate"
    }
  ]

  # Merge provided parameters with production-specific ones
  db_parameters = concat(var.db_parameters, local.postgres_parameters)

  # CloudWatch alarm thresholds (strict for production monitoring)
  cpu_utilization_threshold      = 85
  free_storage_space_threshold   = 5368709120 # 5 GB
  freeable_memory_threshold      = 268435456  # 256 MB
  database_connections_threshold = 200
}