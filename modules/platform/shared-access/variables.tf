# -------------------------------------------------------------
# Naming & Toggle Variables
# -------------------------------------------------------------
variable "name_prefix" {
  description = "Prefix for naming resources (e.g., project-env)"
  type        = string
}

variable "is_internal_alb" {
  description = "Boolean to determine if ALBs are internal or internet-facing"
  type        = bool
}

variable "is_ebs_encrypted" {
  description = "Boolean to determine if Jenkins EBS volume is encrypted"
  type        = bool
}

# -------------------------------------------------------------
# Network Variables
# -------------------------------------------------------------
variable "vpc_id" {
  description = "The ID of the VPC where shared access resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Application Load Balancers"
  type        = list(string)
}

# -------------------------------------------------------------
# Port Configurations
# -------------------------------------------------------------
variable "lb_port" {
  description = "The port for the Application Load Balancer"
  type        = number
}

variable "jenkins_port" {
  description = "The port used by Jenkins"
  type        = number
}

variable "nexus_port" {
  description = "The port used by Nexus"
  type        = number
}

variable "sonar_port" {
  description = "The port used by SonarQube"
  type        = number
}

variable "postgres_port" {
  description = "The port used by PostgreSQL database"
  type        = number
}

# -------------------------------------------------------------
# Health Check Paths
# -------------------------------------------------------------
variable "jenkins_hc_path" {
  description = "Health check path for Jenkins Target Group"
  type        = string
}

variable "nexus_hc_path" {
  description = "Health check path for Nexus Target Group"
  type        = string
}

variable "sonar_hc_path" {
  description = "Health check path for SonarQube Target Group"
  type        = string
}

variable "sonar_hc_matcher" {
  description = "Success code for SonarQube health check (e.g., \"200\")"
  type        = string
}

# -------------------------------------------------------------
# Storage Configurations
# -------------------------------------------------------------
variable "jenkins_ebs_size" {
  description = "The size of the EBS volume for Jenkins in GB"
  type        = number
}

variable "jenkins_ebs_type" {
  description = "The type of EBS volume for Jenkins (e.g., gp2, gp3)"
  type        = string
}

# -------------------------------------------------------------
# Metadata
# -------------------------------------------------------------
variable "tags" {
  description = "A map of tags to apply to all shared access resources"
  type        = map(string)
}
