locals {
  environment = "test"

  # Base tags applied to everything in this environment
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }

  # The ultimate tag map to pass to your modules.
  # This merges the common tags, any extra variables, AND the test-specific AutoCleanup tag.
  environment_tags = merge(
    local.common_tags,
    var.extra_tags,
    {
      AutoCleanup = "true"
    }
  )

  # Test-specific RDS configuration overrides
  # Test uses smaller instances and less redundancy
  multi_az            = false   # No Multi-AZ for test
  deletion_protection = false   # Allow deletion in test
  skip_final_snapshot = true    # Skip final snapshot in test

  # Performance Insights retention (minimum for test)
  performance_insights_retention_period = 7

  # Test backup retention
  backup_retention_period = var.backup_retention_period

  # Test environment specific parameters for PostgreSQL
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
      value        = "1000"
      apply_method = "immediate"
    }
  ]

  # Merge provided parameters with test-specific ones
  db_parameters = concat(var.db_parameters, local.postgres_parameters)

  # CloudWatch alarm thresholds (more relaxed for test)
  cpu_utilization_threshold      = 90
  free_storage_space_threshold   = 2147483648 # 2 GB
  freeable_memory_threshold      = 134217728  # 128 MB
  database_connections_threshold = 50
}