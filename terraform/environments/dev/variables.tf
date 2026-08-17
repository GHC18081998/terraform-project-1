variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Owner team"
  type        = string
}

# ---- VPC Configuration ----
variable "vpc_configs" {
  description = "VPC configurations for this environment. Add more VPCs by adding entries."
  type = map(object({
    cidr_block           = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    instance_tenancy     = optional(string, "default")
    tags                 = optional(map(string), {})
  }))
}

# ---- Public Subnet Configuration ----
variable "public_subnet_configs" {
  description = "Public subnet configurations"
  type = map(object({
    vpc_key           = string
    cidr_block        = string
    availability_zone = string
    map_public_ip     = optional(bool, true)
    tags              = optional(map(string), {})
  }))
}

# ---- Private Subnet Configuration ----
variable "private_subnet_configs" {
  description = "Private subnet configurations"
  type = map(object({
    vpc_key           = string
    cidr_block        = string
    availability_zone = string
    subnet_type       = optional(string, "app")
    tags              = optional(map(string), {})
  }))
}

# ---- NAT Gateway Configuration ----
variable "nat_gateway_configs" {
  description = "NAT Gateway configurations"
  type = map(object({
    public_subnet_key = string
    tags              = optional(map(string), {})
  }))
}

# ---- Public Route Table Configuration ----
variable "public_route_table_configs" {
  description = "Public route table configurations"
  type = map(object({
    vpc_key                   = string
    igw_key                   = string
    associated_public_subnets = list(string)
    tags                      = optional(map(string), {})
  }))
}

# ---- Private Route Table Configuration ----
variable "private_route_table_configs" {
  description = "Private route table configurations"
  type = map(object({
    vpc_key                    = string
    nat_gateway_key            = string
    associated_private_subnets = list(string)
    tags                       = optional(map(string), {})
  }))
}

# ---- vpc endpoint Configuration ----
variable "interface_endpoint_services" {
  description = "AWS service names for interface VPC endpoints"
  type        = list(string)
  default     = ["secretsmanager", "kms", "ssm", "ssmmessages", "ec2messages", "logs"]
}

# ------------------------------------------------------------
# S3 Bucket Configurations
# ------------------------------------------------------------
variable "buckets" {
  description = "Map of bucket configurations"
  type = map(object({
    versioning_enabled                 = optional(bool, true)
    lifecycle_enabled                  = optional(bool, true)
    intelligent_tiering_enabled        = optional(bool, true)
    noncurrent_version_expiration_days = optional(number, 30)
    expiration_days                    = optional(number)
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

# ------------------------------------------------------------
# Secrets Manager Configurations
# ------------------------------------------------------------
variable "secrets" {
  description = "Map of secret configurations"
  type = map(object({
    description          = string
    secret_string        = string
    resource_policy_json = optional(string)
    rotation_lambda_arn  = optional(string)
    rotation_days        = optional(number, 30)
  }))
  default = {}
}

# ------------------------------------------------------------
# IAM Configurations
# ------------------------------------------------------------
variable "iam_roles" {
  description = "Map of IAM roles to create"
  type        = map(any)
  default     = {}
}

variable "iam_policies" {
  description = "Map of custom IAM policies to create"
  type        = map(any)
  default     = {}
}

variable "iam_role_policy_attachments" {
  description = "Map of role policy attachments"
  type        = map(any)
  default     = {}
}

variable "iam_oidc_providers" {
  description = "Map of OIDC identity providers"
  type        = map(any)
  default     = {}
}

variable "iam_oidc_roles" {
  description = "Map of OIDC-assumed roles"
  type        = map(any)
  default     = {}
}

variable "iam_oidc_role_policy_attachments" {
  description = "Map of OIDC role policy attachments"
  type        = map(any)
  default     = {}
}
