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
# Standard IAM Variables
# ==============================================================

variable "roles" {
  description = "Map of role_key => role configuration"
  type = map(object({
    principal_type        = string           # e.g., "Service" or "AWS"
    principal_identifiers = list(string)     # e.g., ["ec2.amazonaws.com"]
    external_id           = optional(string)
  }))
  default = {}
}

variable "policies" {
  description = "Map of policy_key => { description, policy_json }"
  type = map(object({
    description = string
    policy_json = string
  }))
  default = {}
}

variable "role_policy_attachments" {
  description = "Map of attachment_key => { role_key, policy_key } to attach"
  type = map(object({
    role_key   = string
    policy_key = string
  }))
  default = {}
}

# ==============================================================
# OIDC Federation Variables
# ==============================================================

variable "oidc_providers" {
  description = "Map of oidc_provider_key => OIDC identity provider configuration (e.g., GitHub Actions, GitLab CI)"
  type = map(object({
    url             = string       # e.g., "https://token.actions.githubusercontent.com"
    client_id_list  = list(string) # e.g., ["sts.amazonaws.com"]
    thumbprint_list = list(string) # root CA thumbprint(s) for the provider
  }))
  default = {}
}

variable "oidc_roles" {
  description = "Map of oidc_role_key => role configuration, assumed via OIDC federation instead of long-lived AWS keys"
  type = map(object({
    provider_key   = string                                  # key into var.oidc_providers
    audience       = optional(string, "sts.amazonaws.com")
    subject_claims = list(string)                            # e.g., ["repo:my-org/my-repo:ref:refs/heads/main"]
  }))
  default = {}
}

variable "oidc_role_policy_attachments" {
  description = "Map of attachment_key => { oidc_role_key, policy_key } to attach existing policies to OIDC-federated roles"
  type = map(object({
    oidc_role_key = string
    policy_key    = string
  }))
  default = {}
}