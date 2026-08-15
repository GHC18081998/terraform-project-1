# ==============================================================================
# General Variables
# ==============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 30
    error_message = "Project name must be between 1 and 30 characters."
  }
}

variable "environment" {
  description = "Deployment environment (test, prod)"
  type        = string
  validation {
    condition     = contains(["test", "staging", "prod", "production"], var.environment)
    error_message = "Environment must be one of: test, staging, prod, production."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

# ==============================================================================
# Network Variables
# ==============================================================================

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group (minimum 2 for Multi-AZ)"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for RDS subnet group."
  }
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to RDS"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to connect to RDS"
  type        = list(string)
  default     = []
}

# ==============================================================================
# RDS Instance Variables
# ==============================================================================

variable "db_name" {
  description = "Name of the database"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "DB name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_username) >= 1 && length(var.db_username) <= 16
    error_message = "DB username must be between 1 and 16 characters."
  }
}

variable "db_password" {
  description = "Master password for the database (leave empty to auto-generate)"
  type        = string
  sensitive   = true
  default     = ""
  validation {
    condition     = var.db_password == "" || length(var.db_password) >= 8
    error_message = "DB password must be at least 8 characters if provided."
  }
}

variable "engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.engine)
    error_message = "Engine must be one of: mysql, postgres, mariadb."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB (0 to disable)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2, standard."
  }
}

variable "iops" {
  description = "Provisioned IOPS for io1/io2 storage type"
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput in MB/s for gp3 storage"
  type        = number
  default     = null
}

variable "db_port" {
  description = "Database port (null to use engine default)"
  type        = number
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the DB instance is publicly accessible"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately or during next maintenance window"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the instance"
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to DB snapshots"
  type        = bool
  default     = true
}

# ==============================================================================
# Backup Variables
# ==============================================================================

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = ""
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = ""
}

# ==============================================================================
# Encryption Variables
# ==============================================================================

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Create a new KMS key for RDS encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Existing KMS key ID for encryption (used when create_kms_key is false)"
  type        = string
  default     = null
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_rotation_enabled" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}

# ==============================================================================
# Monitoring Variables
# ==============================================================================

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "create_monitoring_role" {
  description = "Create IAM role for enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "Existing IAM role ARN for enhanced monitoring"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = null
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for RDS monitoring"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm recovers"
  type        = list(string)
  default     = []
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization alarm threshold percentage"
  type        = number
  default     = 80
}

variable "free_storage_space_threshold" {
  description = "Free storage space alarm threshold in bytes"
  type        = number
  default     = 5368709120 # 5 GB
}

variable "freeable_memory_threshold" {
  description = "Freeable memory alarm threshold in bytes"
  type        = number
  default     = 268435456 # 256 MB
}

variable "database_connections_threshold" {
  description = "Database connections alarm threshold"
  type        = number
  default     = 100
}

# ==============================================================================
# Parameter Group Variables
# ==============================================================================

variable "create_parameter_group" {
  description = "Create a custom parameter group"
  type        = bool
  default     = true
}

variable "parameter_group_family" {
  description = "Parameter group family (null to auto-detect)"
  type        = string
  default     = null
}

variable "db_parameters" {
  description = "List of DB parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# ==============================================================================
# Option Group Variables
# ==============================================================================

variable "create_option_group" {
  description = "Create a custom option group (MySQL/MariaDB only)"
  type        = bool
  default     = false
}

variable "option_group_options" {
  description = "List of options for the option group"
  type = list(object({
    option_name = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []
}