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

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
}

# ============================================================
# EKS & Karpenter Configurations (ADDED)
# ============================================================
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "kms_key_administrators" {
  description = "List of IAM ARNs allowed to administer KMS keys"
  type        = list(string)
  default     = []
}

variable "node_pools" {
  description = "Karpenter node pool specifications"
  type        = map(any)
  default     = {}
}

variable "aws_auth_roles" {
  description = "Additional IAM roles mapped to Kubernetes RBAC groups"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# ============================================================
# DNS (Route53) Configurations (ADDED)
# ============================================================
variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
  default     = ""
}

variable "route53_zone_name" {
  description = "Route53 Hosted Zone Name"
  type        = string
  default     = ""
}

# ============================================================
# VPC Configurations
# ============================================================
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

variable "nat_gateway_configs" {
  description = "NAT Gateway configurations"
  type = map(object({
    public_subnet_key = string
    tags              = optional(map(string), {})
  }))
}

variable "public_route_table_configs" {
  description = "Public route table configurations"
  type = map(object({
    vpc_key                     = string
    igw_key                     = string
    associated_public_subnets = list(string)
    tags                        = optional(map(string), {})
  }))
}

variable "private_route_table_configs" {
  description = "Private route table configurations"
  type = map(object({
    vpc_key                    = string
    nat_gateway_key            = optional(string)
    associated_private_subnets = list(string)
    tags                       = optional(map(string), {})
  }))
}

# ============================================================
# VPC Endpoint Configurations
# ============================================================
variable "interface_endpoint_services" {
  description = "AWS service names for interface VPC endpoints"
  type        = list(string)
  default     = ["secretsmanager", "kms", "ssm", "ssmmessages", "ec2messages", "logs"]
}

variable "enable_s3_endpoint" {
  description = "Enable S3 Gateway VPC endpoint across the specified VPCs"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB Gateway VPC endpoint across the specified VPCs"
  type        = bool
  default     = true
}

# ============================================================
# S3 Bucket Configurations
# ============================================================
variable "s3_buckets" {
  description = "Map of bucket configurations"
  type = map(object({
    versioning_enabled                   = optional(bool, true)
    lifecycle_enabled                    = optional(bool, true)
    intelligent_tiering_enabled          = optional(bool, true)
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

# ============================================================
# Secrets Manager Configurations
# ============================================================
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

# ============================================================
# IAM Configurations
# ============================================================
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

# ============================================================
# ECR (Elastic Container Registry) Configurations
# ============================================================
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

# ============================================================
# Database (RDS) Configurations
# ============================================================
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password (leave empty to auto-generate)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
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
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 50
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 3
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 0
}

variable "alarm_actions" {
  description = "SNS topic ARNs for alarm notifications"
  type        = list(string)
  default     = []
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

variable "db_parameters" {
  description = "List of DB parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "kms_key_arn" {
  description = "Optional custom KMS key ARN"
  type        = string
  default     = null
}

variable "eks_addons" {
  description = "Map of native EKS addons configuration"
  type = map(object({
    version                  = optional(string)
    service_account_role_arn = optional(string)
  }))
  default = {}
}