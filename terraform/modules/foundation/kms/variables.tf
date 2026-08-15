# ==============================================================
# Global Variables
# ==============================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev/test/prod)"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# ==============================================================
# KMS Specific Variables
# ==============================================================

variable "key_purpose" {
  description = "Short name indicating what this key is for (e.g., 'rds', 'eks', 's3')"
  type        = string
}

variable "description" {
  description = "Detailed description of the KMS key"
  type        = string
  default     = "Managed by Terraform"
}

variable "deletion_window_in_days" {
  description = "Number of days before the key is permanently deleted (7-30)"
  type        = number
  default     = 30
}

variable "allowed_service_principals" {
  description = "List of AWS Service principals allowed to use this key (e.g., ['rds.amazonaws.com'])"
  type        = list(string)
  default     = []
}