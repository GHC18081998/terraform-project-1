# ==============================================================
# Global Variables
# ==============================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "bootstrap"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# ==============================================================
# S3 Variables (State Storage)
# ==============================================================

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Enable versioning on S3 bucket"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent versions expire"
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even with objects"
  type        = bool
  default     = false
}

# ==============================================================
# DynamoDB Variables (State Locking)
# ==============================================================

variable "table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be either PAY_PER_REQUEST or PROVISIONED"
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB Point-in-Time Recovery"
  type        = bool
  default     = true
}

# ==============================================================
# KMS Variables (State Encryption)
# ==============================================================

variable "kms_key_arn" {
  description = "The ARN of the KMS key for DynamoDB/S3 encryption"
  type        = string
}

variable "kms_alias_name" {
  description = "Alias name for KMS key"
  type        = string
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for Terraform state encryption"
}

variable "kms_deletion_window_in_days" {
  description = "Duration in days before the key is permanently deleted"
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}
