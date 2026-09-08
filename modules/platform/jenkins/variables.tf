variable "subnet_id" {
  description = "The private subnet ID where the Jenkins EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the Jenkins instance"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the ALB Target Group to attach the Jenkins instance to"
  type        = string
}

variable "ebs_volume_id" {
  description = "The ID of the shared EBS volume to attach for Jenkins data storage"
  type        = string
}


variable "instance_type" {
  description = "The EC2 instance type for the Jenkins server"
  type        = string
}

variable "jenkins_port" {
  description = "The application port Jenkins listens on (typically 8080)"
  type        = number
}

variable "java_version" {
  description = "The version of Amazon Corretto Java to install (e.g., '17')"
  type        = string
}
  
variable "iam_instance_profile" {
  description = "IAM instance profile name for the Jenkins instance"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}
