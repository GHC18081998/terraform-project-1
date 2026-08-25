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

variable "kms_key_arn" {
  description = "Default KMS key ARN used for S3 bucket encryption"
  type        = string
}

# ==============================================================
# S3 Variables
# ==============================================================

variable "buckets" {
  description = "Map of bucket_key => bucket configuration. Add a new bucket by adding a new map entry — no module code changes needed."
  type = map(object({

    # Secure and resilient by default
    versioning_enabled                 = optional(bool, true)

    # Cost-optimized by default
    lifecycle_enabled                  = optional(bool, true)
    intelligent_tiering_enabled        = optional(bool, true)

    # Cleans up old versions automatically after 30 days
    noncurrent_version_expiration_days = optional(number, 30)
    expiration_days                    = optional(number)

    # Aggressive default transition to save money on storage
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [
      { days = 30, storage_class = "STANDARD_IA" },
      { days = 90, storage_class = "GLACIER" }
    ])

    tags = optional(map(string), {})
  }))
  default = {}
}
