# ==============================================================
# Global Variables
# ==============================================================
variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "owner" { type = string }

# ==============================================================
# Structural Configurations (Passed from Environment tfvars)
# ==============================================================
variable "vpc_configs" { type = map(any) }
variable "public_route_table_configs" { type = map(any) }
variable "private_route_table_configs" { type = map(any) }
variable "private_subnet_configs" { type = map(any) }

# ==============================================================
# Generated Resource IDs (Passed from the VPC Module)
# ==============================================================
variable "vpc_ids" {
  description = "Map of VPC keys to their generated AWS VPC IDs"
  type        = map(string)
}
variable "public_route_table_ids" {
  description = "Map of Public Route Table keys to their AWS IDs"
  type        = map(string)
}
variable "private_route_table_ids" {
  description = "Map of Private Route Table keys to their AWS IDs"
  type        = map(string)
}
variable "private_subnet_ids" {
  description = "Map of Private Subnet keys to their AWS IDs"
  type        = map(string)
}

# ==============================================================
# Endpoint Specific Settings
# ==============================================================
variable "interface_endpoint_services" {
  description = "AWS service names for interface VPC endpoints"
  type        = list(string)
  default     = ["secretsmanager", "kms", "ssm", "ssmmessages", "ec2messages", "logs"]
}

variable "enable_s3_endpoint" {
  type    = bool
  default = true
}

variable "enable_dynamodb_endpoint" {
  type    = bool
  default = true
}