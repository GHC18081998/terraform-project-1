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