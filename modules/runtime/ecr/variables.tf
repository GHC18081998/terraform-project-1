variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., test, prod)"
}

variable "repositories" {
  type = map(object({
    image_tag_mutability       = string
    scan_on_push               = bool
    untagged_image_expiry_days = number
    tagged_image_max_count     = number
    tagged_prefixes            = list(string)
  }))
  description = "Map of ECR repositories to create and their specific lifecycle/scanning parameters"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to append to all repositories"
}

# --- ADD THESE IF YOU KEEP scanning.tf ---

variable "enable_registry_scanning" {
  type        = bool
  description = "Enable registry-level scanning"
  default     = false
}

variable "registry_scan_type" {
  type        = string
  description = "BASIC or ENHANCED scanning"
  default     = "BASIC"
}

variable "registry_scan_frequency" {
  type        = string
  description = "SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL"
  default     = "SCAN_ON_PUSH"
}

variable "create_kms_key" {
  description = "Determines whether a new KMS key should be created for ECR"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of an existing KMS key to use if create_kms_key is false"
  type        = string
  default     = null
}

# ==============================================================
# KMS Encryption Variables
# ==============================================================
variable "kms_key_description" {
  description = "Description for the ECR KMS key"
  type        = string
  default     = "KMS key used for ECR repository encryption"
}

variable "kms_key_deletion_window_in_days" {
  description = "Waiting period before AWS permanently deletes the KMS key"
  type        = number
  default     = 7
}

variable "kms_key_enable_rotation" {
  description = "Enable automatic annual rotation of the KMS key"
  type        = bool
  default     = true
}

variable "kms_key_multi_region" {
  description = "Whether the KMS key is a multi-region key"
  type        = bool
  default     = false
}
