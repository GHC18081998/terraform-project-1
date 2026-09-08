variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_username" {
  description = "Database username for SonarQube"
  type        = string
}

# ============================================================
# Network & Security
# ============================================================
variable "subnet_id" {
  description = "The private subnet ID where the SonarQube EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the SonarQube EC2 instance"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the ALB Target Group to attach the SonarQube instance to"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the SonarQube instance"
  type        = string
}

# ============================================================
# Application & Docker Configuration
# ============================================================
variable "instance_type" {
  description = "The EC2 instance type for the SonarQube server"
  type        = string
}

variable "sonarqube_version" {
  description = "The specific version of SonarQube to download and install"
  type        = string
}

variable "sonar_image" {
  description = "The SonarQube Docker image tag to deploy"
  type        = string
}

variable "sonarqube_port" {
  description = "The application port SonarQube listens on"
  type        = number
}

variable "sonar_host_port" {
  description = "The EC2 host port exposed to the container"
  type        = number
}

variable "sonar_container_port" {
  description = "The internal port SonarQube listens on inside the container"
  type        = number
}

variable "sonar_container_name" {
  description = "The name assigned to the SonarQube Docker container"
  type        = string
}

variable "docker_repo_url" {
  description = "The repository URL to download Docker"
  type        = string
}

variable "docker_package" {
  description = "The name of the Docker package to install"
  type        = string
}

variable "java_version" {
  description = "The version of Amazon Corretto Java to install"
  type        = string
}

# ============================================================
# Database Configuration (Dockerized PostgreSQL)
# ============================================================
variable "postgres_version" {
  description = "The version of PostgreSQL server to install via Docker"
  type        = string
}

variable "db_port" {
  description = "The local port PostgreSQL listens on"
  type        = number
}

# ============================================================
# Secrets Manager Integration
# ============================================================

variable "aws_region" {
  description = "The AWS region where the Secrets Manager secret is located"
  type        = string
}

# ============================================================
# General
# ============================================================
variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
}

variable "ebs_volume_size" {
  description = "Size of the SonarQube EBS volume in GB"
  type        = number
}

variable "ebs_volume_type" {
  description = "Type of the SonarQube EBS volume"
  type        = string
}

variable "s3_backup_bucket" {
  description = "The name of the S3 bucket where database backups will be stored"
  type        = string
}

variable "sonar_password_length" {
  description = "Length of the SonarQube database password"
  type        = number
}

variable "sonar_password_special" {
  description = "Whether to include special characters in the password"
  type        = bool
}

variable "sonar_password_override_special" {
  description = "Supplied special characters allowed in the password"
  type        = string
}

variable "secret_id" {
  description = "Secret ID for SonarQube"
  type        = string
}

variable "postgres_volume_size" {
  type = number
}

variable "postgres_volume_type" {
  type = string
}

variable "postgres_volume_encrypted" {
  type = bool
}

variable "postgres_device_name" {
  type = string
}

variable "ebs_encrypted" {
  type = bool
}

variable "ebs_delete_on_termination" {
  type = bool
}

variable "secret_recovery_window_in_days" {
  type = number
}

variable "sonarqube_data_volume_size" {
  type = number
}

variable "sonarqube_data_volume_type" {
  type = string
}

variable "sonarqube_data_volume_encrypted" {
  type = bool
}

variable "sonarqube_data_device_name" {
  type = string
}

variable "postgres_volume_prevent_destroy" {
  type = bool
}

variable "sonarqube_data_prevent_destroy" {
  type = bool
}
