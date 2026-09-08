variable "subnet_id" {
  description = "The private subnet ID where the Nexus EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the Nexus instance"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the ALB Target Group to attach the Nexus instance to"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the Nexus server"
  type        = string
}

variable "nexus_port" {
  description = "The application port Nexus listens on (typically 8081)"
  type        = number
  default     = 8081
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the Nexus instance"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}

# Application Variables for userdata.sh

variable "app_dir" {
  description = "The base directory where Nexus and its data will be installed"
  type        = string
  default     = "/app"
}

variable "nexus_version" {
  description = "Nexus OSS version to deploy (e.g., 3.78.2-04)"
  type        = string
}

variable "java_package" {
  description = "The Java package name required to run Nexus"
  type        = string
  default     = "java-21-amazon-corretto-devel"
}

variable "nexus_user" {
  description = "The dedicated OS user and group created to run the Nexus service"
  type        = string
  default     = "nexus"
}
