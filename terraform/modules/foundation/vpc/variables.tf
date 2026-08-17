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
  description = "Environment name (e.g., dev/test/prod)"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# ==============================================================
# Network Configurations (Resource Definitions)
# ==============================================================

variable "vpc_configs" {
  description = "Map of VPC configurations - supports multiple VPCs per environment"
  type = map(object({
    cidr_block           = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    instance_tenancy     = optional(string, "default")
    tags                 = optional(map(string), {})
  }))
}

variable "public_subnet_configs" {
  description = "Map of public subnet configurations"
  type = map(object({
    vpc_key           = string
    cidr_block        = string
    availability_zone = string
    map_public_ip     = optional(bool, true)
    tags              = optional(map(string), {})
  }))
}

variable "private_subnet_configs" {
  description = "Map of private subnet configurations"
  type = map(object({
    vpc_key           = string
    cidr_block        = string
    availability_zone = string
    subnet_type       = optional(string, "app") # app, data, eks
    tags              = optional(map(string), {})
  }))
}

variable "public_route_table_configs" {
  description = "Map of public route table configurations"
  type = map(object({
    vpc_key                   = string
    igw_key                   = string
    associated_public_subnets = list(string)
    tags                      = optional(map(string), {})
  }))
}

variable "private_route_table_configs" {
  description = "Map of private route table configurations"
  type = map(object({
    vpc_key                    = string
    nat_gateway_key            = string
    associated_private_subnets = list(string)
    tags                       = optional(map(string), {})
  }))
}

variable "nat_gateway_configs" {
  description = "Map of NAT Gateway configurations - one per public subnet desired"
  type = map(object({
    public_subnet_key = string
    tags              = optional(map(string), {})
  }))
}

# ==============================================================
# VPC Endpoint Configurations
# ==============================================================

variable "interface_endpoint_services" {
  description = "AWS service names for interface VPC endpoints (e.g. secretsmanager, kms, ec2, ssm, ssmmessages, ec2messages, logs)"
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
