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
# EKS & Karpenter Configurations
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

variable "aws_auth_users" {
  description = "List of IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# ============================================================
# DNS (Route53) Configurations
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
  description = "VPC configurations for this environment."
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
    vpc_key                   = string
    igw_key                   = string
    associated_public_subnets = list(string)
    tags                      = optional(map(string), {})
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

# ============================================================
# Secrets Manager Configurations
# ============================================================
variable "secrets" {
  description = "Map of secret configurations"
  type = map(object({
    description          = string
    username             = string
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
  type    = map(any)
  default = {}
}

variable "iam_policies" {
  type    = map(any)
  default = {}
}

variable "iam_role_policy_attachments" {
  type    = map(any)
  default = {}
}

variable "iam_oidc_providers" {
  type    = map(any)
  default = {}
}

variable "iam_oidc_roles" {
  type    = map(any)
  default = {}
}

variable "iam_oidc_role_policy_attachments" {
  type    = map(any)
  default = {}
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
}

variable "extra_tags" {
  type    = map(string)
  default = {}
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

# ============================================================
# DynamoDB Configurations
# ============================================================
variable "dynamodb_tables" {
  type = map(object({
    hash_key       = string
    range_key      = optional(string)
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    read_capacity  = optional(number, null)
    write_capacity = optional(number, null)
    attributes = list(object({
      name = string
      type = string
    }))
    global_secondary_indexes = optional(list(object({
      name               = string
      hash_key           = string
      range_key          = optional(string)
      projection_type    = string
      non_key_attributes = optional(list(string))
    })), [])
  }))
  default = {}
}

# ==============================================================================
# AWS Load Balancer Controller Variables
# ==============================================================================

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = true
}

variable "lb_controller_replica_count" {
  type    = number
  default = 1
}

variable "lb_controller_chart_version" {
  type    = string
  default = "1.7.1"
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "enable_wafv2" {
  type    = bool
  default = false
}

variable "enable_shield" {
  type    = bool
  default = false
}

# ==============================================================================
# Application Ports & Storage Configurations
# ==============================================================================

variable "lb_port" {
  description = "Application Load Balancer listener port"
  type        = number
}

variable "jenkins_port" {
  description = "Jenkins application port"
  type        = number
}

variable "nexus_port" {
  description = "Nexus application port"
  type        = number
}

variable "sonar_port" {
  description = "SonarQube application port"
  type        = number
}

variable "postgres_port" {
  description = "PostgreSQL database port"
  type        = number
}

variable "jenkins_ebs_size" {
  description = "Size of the Jenkins EBS data volume in GB"
  type        = number
}

variable "jenkins_ebs_type" {
  description = "Type of the Jenkins EBS data volume (e.g., gp3)"
  type        = string
}

variable "sonarqube_ebs_size" {
  description = "Size of the SonarQube EBS data volume in GB"
  type        = number
}

variable "sonarqube_ebs_type" {
  description = "Type of the SonarQube EBS data volume (e.g., gp3)"
  type        = string
}

# ==============================================================================
# Tools Server Configurations (Versions, Instances & AMIs)
# ==============================================================================

variable "jenkins_instance_type" {
  description = "EC2 Instance type for Jenkins"
  type        = string
}

variable "jenkins_java_version" {
  description = "Java version for Jenkins"
  type        = string
}

variable "jenkins_ami_filter" {
  description = "AMI name filter for Jenkins (e.g., al2023-ami-2023.*-x86_64)"
  type        = string
}

variable "jenkins_ami_architecture" {
  description = "AMI architecture for Jenkins"
  type        = string
}

variable "nexus_instance_type" {
  description = "EC2 Instance type for Nexus"
  type        = string
}

variable "nexus_version" {
  description = "The specific version of Nexus Repository Manager to deploy"
  type        = string
}

variable "nexus_java_package" {
  description = "The Java package name required to run Nexus"
  type        = string
}

variable "nexus_ami_filter" {
  description = "AMI name filter for Nexus"
  type        = string
}

variable "nexus_ami_architecture" {
  description = "AMI architecture for Nexus"
  type        = string
}

variable "sonarqube_instance_type" {
  description = "EC2 Instance type for SonarQube"
  type        = string
}

variable "sonarqube_version" {
  description = "The specific version of SonarQube to deploy"
  type        = string
}

variable "sonarqube_java_version" {
  description = "Java version for SonarQube"
  type        = string
}

variable "sonarqube_postgres_version" {
  description = "PostgreSQL Docker image version for SonarQube (e.g., 15)"
  type        = string
}

variable "sonarqube_ami_filter" {
  description = "AMI name filter for SonarQube"
  type        = string
}

variable "sonarqube_ami_architecture" {
  description = "AMI architecture for SonarQube"
  type        = string
}

variable "sonarqube_docker_image" {
  description = "Docker image tag for SonarQube"
  type        = string
}

variable "sonar_host_port" {
  description = "Host port for SonarQube container"
  type        = number
}

variable "sonar_container_port" {
  description = "Container port for SonarQube"
  type        = number
}

variable "sonar_container_name" {
  description = "Name of the SonarQube container"
  type        = string
}

variable "docker_repo_url" {
  description = "Docker repository URL for yum/dnf"
  type        = string
}

variable "docker_package" {
  description = "Docker package name to install"
  type        = string
}

variable "sonarqube_db_username" {
  description = "Database username for SonarQube"
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

# ==============================================================================
# Shared Access Toggles & Health Checks
# ==============================================================================
variable "shared_is_internal_alb" {
  description = "Boolean to determine if ALBs are internal or internet-facing"
  type        = bool
}

variable "shared_is_ebs_encrypted" {
  description = "Boolean to determine if Jenkins EBS volume is encrypted"
  type        = bool
}

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

variable "sonarqube_data_ebs_size" {
  type = number
}

variable "sonarqube_data_ebs_type" {
  type = string
}

variable "sonarqube_data_encrypted" {
  type = bool
}

variable "sonarqube_data_device_name" {
  type = string
}


variable "postgres_volume_size" {
  type        = number
  description = "Size of the dedicated PostgreSQL EBS volume in GB"
}

variable "postgres_volume_type" {
  type        = string
  description = "EBS volume type for PostgreSQL data"
}

variable "postgres_volume_encrypted" {
  type        = bool
  description = "Enable encryption on the PostgreSQL EBS volume"
}

variable "postgres_device_name" {
  type        = string
  description = "Device name for attaching the PostgreSQL EBS volume"
}

variable "sonarqube_ebs_encrypted" {
  type        = bool
  description = "Enable encryption on SonarQube root EBS volume"
}

variable "sonarqube_ebs_delete_on_termination" {
  type        = bool
  description = "Whether to delete the root EBS volume on instance termination"
}

variable "secret_recovery_window_in_days" {
  type        = number
  description = "Recovery window in days for Secrets Manager secrets"
}

# ============================================================
# EKS Bootstrap Node Variables
# ============================================================
variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS public API endpoint"
  type        = list(string)
}

variable "eks_bootstrap_instance_types" {
  description = "Instance types for the EKS bootstrap node group"
  type        = list(string)
}

variable "eks_bootstrap_min_size" {
  description = "Minimum size of the bootstrap node group"
  type        = number
}

variable "eks_bootstrap_max_size" {
  description = "Maximum size of the bootstrap node group"
  type        = number
}

variable "eks_bootstrap_desired_size" {
  description = "Desired size of the bootstrap node group"
  type        = number
}
