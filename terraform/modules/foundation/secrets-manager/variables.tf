# ==============================================================
# Global Variables
# ==============================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# ==============================================================
# Secrets Manager Variables
# ==============================================================

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt secrets"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0
}

variable "secrets" {
  description = "Map of secret_key => secret configuration"
  type = map(object({
    description          = string
    secret_string        = string
    resource_policy_json = optional(string)
    rotation_lambda_arn  = optional(string)
    rotation_days        = optional(number, 30)
  }))
  default = {}
}