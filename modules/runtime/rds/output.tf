# ==============================================================================
# RDS Instance Outputs
# ==============================================================================

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.rds.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.rds.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint (host:port)"
  value       = aws_db_instance.rds.endpoint
}

output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds.address
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.rds.db_name
}

output "db_instance_username" {
  description = "Master username"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "db_instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.rds.instance_class
}

output "db_instance_engine" {
  description = "Database engine"
  value       = aws_db_instance.rds.engine
}

output "db_instance_engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.rds.engine_version_actual
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.rds.status
}

output "db_instance_multi_az" {
  description = "Whether Multi-AZ is enabled"
  value       = aws_db_instance.rds.multi_az
}

output "db_instance_availability_zone" {
  description = "Availability zone of the RDS instance"
  value       = aws_db_instance.rds.availability_zone
}

output "db_instance_storage_encrypted" {
  description = "Whether storage is encrypted"
  value       = aws_db_instance.rds.storage_encrypted
}

output "db_instance_allocated_storage" {
  description = "Allocated storage in GB"
  value       = aws_db_instance.rds.allocated_storage
}

output "db_instance_backup_retention_period" {
  description = "Backup retention period in days"
  value       = aws_db_instance.rds.backup_retention_period
}

output "db_instance_resource_id" {
  description = "RDS instance resource ID"
  value       = aws_db_instance.rds.resource_id
}

# ==============================================================================
# Security Group Outputs
# ==============================================================================

output "security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.rds.id
}

output "security_group_arn" {
  description = "Security group ARN for the RDS instance"
  value       = aws_security_group.rds.arn
}

output "security_group_name" {
  description = "Security group name for the RDS instance"
  value       = aws_security_group.rds.name
}

# ==============================================================================
# Subnet Group Outputs
# ==============================================================================

output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.rds.id
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.rds.arn
}

# ==============================================================================
# Parameter Group Outputs
# ==============================================================================

output "db_parameter_group_id" {
  description = "DB parameter group ID"
  value       = var.create_parameter_group ? aws_db_parameter_group.rds[0].id : null
}

output "db_parameter_group_arn" {
  description = "DB parameter group ARN"
  value       = var.create_parameter_group ? aws_db_parameter_group.rds[0].arn : null
}

# ==============================================================================
# KMS Key Outputs
# ==============================================================================

output "kms_key_id" {
  description = "KMS key ID used for RDS encryption"
  value       = var.create_kms_key && var.storage_encrypted ? aws_kms_key.rds[0].key_id : var.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for RDS encryption"
  value       = var.create_kms_key && var.storage_encrypted ? aws_kms_key.rds[0].arn : null
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = var.create_kms_key && var.storage_encrypted ? aws_kms_alias.rds[0].name : null
}

# ==============================================================================
# Monitoring Outputs
# ==============================================================================

output "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring"
  value       = var.create_monitoring_role && var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
}

output "monitoring_role_name" {
  description = "IAM role name for enhanced monitoring"
  value       = var.create_monitoring_role && var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].name : null
}


# ==============================================================================
# Secrets Manager Outputs
# ==============================================================================

output "db_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_secret_name" {
  description = "Secrets Manager secret name for DB credentials"
  value       = aws_secretsmanager_secret.db_password.name
}

# ==============================================================================
# Connection String Outputs
# ==============================================================================

output "db_connection_string" {
  description = "Database connection string (without password)"
  value       = "${var.engine}://${var.db_username}@${aws_db_instance.rds.endpoint}/${var.db_name}"
  sensitive   = false
}