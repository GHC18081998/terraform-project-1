# ==============================================================
# TEST Environment Configuration
# ==============================================================
# Location: environments/test/terraform.tfvars

aws_region   = "us-east-1"
project_name = "myproject"
environment  = "test"
owner        = "aws-devops-team"
account_id   = "463200133372"

# --------------------------------------------------------------
# EXACTLY 1 VPC
# --------------------------------------------------------------
vpc_configs = {
  "main-vpc" = { cidr_block = "10.0.0.0/16", enable_dns_hostnames = true, enable_dns_support = true }
}

# --------------------------------------------------------------
# MINIMAL SUBNETS (2 Public, 2 Private for AWS EKS/RDS rules)
# --------------------------------------------------------------
public_subnet_configs = {
  "main-pub-1a" = { vpc_key = "main-vpc", cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a", map_public_ip = true }
  "main-pub-1b" = { vpc_key = "main-vpc", cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b", map_public_ip = true }
}

private_subnet_configs = {
  "main-priv-1a" = { vpc_key = "main-vpc", cidr_block = "10.0.10.0/24", availability_zone = "us-east-1a", subnet_type = "app" }
  "main-priv-1b" = { vpc_key = "main-vpc", cidr_block = "10.0.11.0/24", availability_zone = "us-east-1b", subnet_type = "app" }
}

# --------------------------------------------------------------
# EXACTLY 1 NAT GATEWAY
# --------------------------------------------------------------
nat_gateway_configs = {
  "main-nat" = { public_subnet_key = "main-pub-1a" }
}

# --------------------------------------------------------------
# ROUTE TABLES
# --------------------------------------------------------------
public_route_table_configs = {
  "main-pub-rt" = {
    vpc_key                   = "main-vpc"
    igw_key                   = "main-vpc"
    associated_public_subnets = ["main-pub-1a", "main-pub-1b"]
  }
}

private_route_table_configs = {
  "main-priv-rt" = {
    vpc_key                    = "main-vpc"
    nat_gateway_key            = "main-nat"
    associated_private_subnets = ["main-priv-1a", "main-priv-1b"]
  }
}

# --------------------------------------------------------------
# VPC Endpoints Configuration
# --------------------------------------------------------------
enable_s3_endpoint       = true
enable_dynamodb_endpoint = true

interface_endpoint_services = [
  "secretsmanager",
  "kms"
]

# --------------------------------------------------------------
# EKS Cluster & Karpenter Configuration
# --------------------------------------------------------------
cluster_name           = "test-eks-cluster"
cluster_version        = "1.31"
kms_key_administrators = [
  "arn:aws:iam::463200133372:role/AdminRole",
]

# Karpenter NodePools configuration
node_pools = {
  general = {
    instance_families    = ["m5", "m6i", "c6i"]
    instance_sizes       = ["large", "xlarge"]
    capacity_types       = ["spot", "on-demand"]
    arch                 = ["amd64"]
    ami_family           = "AL2023"
    min_cpu              = "2"
    max_cpu              = "100"
    min_memory           = "4Gi"
    max_memory           = "400Gi"
    labels               = { "workload-type" = "general" }
    taints               = []
    consolidation_policy = "WhenUnderutilized"
    expire_after         = "720h"
  }
}

# --------------------------------------------------------------
# EKS Cluster Authentication
# --------------------------------------------------------------
aws_auth_roles = [
  {
    userarn  = "arn:aws:iam::463200133372:"role/LabRole # Replace with your actual Account ID and Username
    username = "console-admin"
    groups   = ["system:masters"]
  }
]

aws_auth_users = []


# --------------------------------------------------------------
# S3 Buckets Configuration
# --------------------------------------------------------------
s3_buckets = {
  # 1. Your Original Terraform State Bucket
  "myproject-terraform-state-locking-bucket" = {
    versioning_enabled = true
    # Note: We do not put expiration days or tiering on the state bucket
    # to ensure your state files are never accidentally moved or deleted.
  }

  # 2. Application Logs
  "app-logs" = {
    versioning_enabled = false
    expiration_days    = 120
  }

  # 3. User Uploads
  "app-user-uploads" = {
    versioning_enabled          = true
    intelligent_tiering_enabled = true
  }

  # 4. Database Backups
  "app-db-backups" = {
    versioning_enabled = true
    expiration_days    = 365
  }
}

# --------------------------------------------------------------
# Secrets Manager Configuration
# --------------------------------------------------------------
secrets = {
  "database-credentials-v2" = {
    description   = "Primary database credentials"
    secret_string = "{\"username\":\"dbadmin\",\"password\":\"changeme\"}"
  }
}

# --------------------------------------------------------------
# IAM Roles & Custom Policies
# --------------------------------------------------------------
iam_roles = {
  "ec2-app-role" = {
    description           = "Role for EC2 application servers"
    principal_type        = "Service"
    principal_identifiers = ["ec2.amazonaws.com"]
  }
}

iam_policies = {
  "s3-full-access" = {
    description = "Provides full access to all S3 buckets"
    policy_json = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [{ "Effect": "Allow", "Action": ["s3:*"], "Resource": "*" }]
    }
    EOF
  }

  "dynamodb-full-access" = {
    description = "Provides full access to all DynamoDB tables"
    policy_json = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [{ "Effect": "Allow", "Action": ["dynamodb:*"], "Resource": "*" }]
    }
    EOF
  }

  "TerraformIAMBuilderPolicy" = {
    description = "Allows Terraform to manage IAM Roles and Instance Profiles"
    policy_json = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformIAMManagement",
          "Effect": "Allow",
          "Action": [
            "iam:CreateRole", "iam:GetRole", "iam:DeleteRole", "iam:ListRoleTags",
            "iam:TagRole", "iam:UntagRole", "iam:ListRolePolicies", "iam:GetRolePolicy",
            "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:AttachRolePolicy",
            "iam:DetachRolePolicy", "iam:ListAttachedRolePolicies", "iam:CreateInstanceProfile",
            "iam:GetInstanceProfile", "iam:DeleteInstanceProfile", "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile", "iam:PassRole", "iam:ListInstanceProfilesForRole"
          ],
          "Resource": "*"
        }
      ]
    }
    EOF
  }

  "AllowEIPManagement" = {
    description = "Allows Terraform to manage Elastic IPs for NAT Gateways"
    policy_json = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses", "ec2:AssociateAddress", "ec2:DisassociateAddress"],
          "Resource": "*"
        }
      ]
    }
    EOF
  }

  "kms-key-policy" = {
    description = "Allows Terraform to manage KMS keys for state encryption"
    policy_json = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["kms:CreateKey", "kms:ListKeys", "kms:ListAliases", "kms:DescribeKey", "kms:CreateAlias", "kms:DeleteAlias", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion", "kms:PutKeyPolicy", "kms:GetKeyPolicy", "kms:EnableKeyRotation", "kms:TagResource", "kms:UntagResource"],
          "Resource": "*"
        }
      ]
    }
    EOF
  }
}

iam_role_policy_attachments = {
  "ec2_s3_attach"       = { role_key = "ec2-app-role", policy_key = "s3-full-access" }
  "ec2_dynamodb_attach" = { role_key = "ec2-app-role", policy_key = "dynamodb-full-access" }
}

# --------------------------------------------------------------
# OIDC Configuration (GitHub Actions)
# --------------------------------------------------------------
iam_oidc_providers = {
  "github-actions" = {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  }
}

iam_oidc_roles = {
  "github-deploy-role" = {
    description    = "Role assumed by GitHub Actions via OIDC"
    provider_key   = "github-actions"
    subject_claims = ["repo:GHC18081998/project-1-terraform:*"]
  }
}

iam_oidc_role_policy_attachments = {
  "attach_custom_iam"      = { oidc_role_key = "github-deploy-role", policy_key = "TerraformIAMBuilderPolicy" }
  "attach_custom_eip"      = { oidc_role_key = "github-deploy-role", policy_key = "AllowEIPManagement" }
  "attach_custom_kms"      = { oidc_role_key = "github-deploy-role", policy_key = "kms-key-policy" }
  "attach_custom_dynamodb" = { oidc_role_key = "github-deploy-role", policy_key = "dynamodb-full-access" }
  "attach_custom_s3"       = { oidc_role_key = "github-deploy-role", policy_key = "s3-full-access" }
  "attach_aws_vpc"         = { oidc_role_key = "github-deploy-role", policy_key = "arn:aws:iam::aws:policy/AmazonVPCFullAccess" }
  "attach_aws_ec2"         = { oidc_role_key = "github-deploy-role", policy_key = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" }
  "attach_aws_kms"         = { oidc_role_key = "github-deploy-role", policy_key = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser" }
  "attach_aws_iam"         = { oidc_role_key = "github-deploy-role", policy_key = "arn:aws:iam::aws:policy/IAMReadOnlyAccess" }
}

# --------------------------------------------------------------
# ECR Repositories Configuration
# --------------------------------------------------------------
repositories = {
  "audit-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "auth-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "contact-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "customer-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "file-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "gateway-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "invoice-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "lead-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "notification-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "opportunity-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "quotation-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "report-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "task-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
  "user-service" = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["test", "v"]
  }
}

# --------------------------------------------------------------
# Database Configuration (RDS)
# --------------------------------------------------------------
db_name     = "appdb2"
db_username = "dbadmin"
db_password = ""

engine         = "postgres"
engine_version = "18.4"

instance_class        = "db.t3.micro"
allocated_storage     = 20
max_allocated_storage = 50
storage_type          = "gp2"

backup_retention_period = 0
monitoring_interval     = 0
alarm_actions           = []

allowed_cidr_blocks = [
  "10.0.0.0/8",
  "172.16.0.0/12"
]
allowed_security_group_ids = []

db_parameters = [
  {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }
]

# --------------------------------------------------------------
# DNS Configuration
# --------------------------------------------------------------
route53_zone_id   = "Z1234567890ABCDEFGHIJ"
route53_zone_name = "test.example.com"


# --------------------------------------------------------------
# Global Extra Tags
# --------------------------------------------------------------
extra_tags = {
  CostCenter = "engineering-test"
  Owner      = "qa-team"
  Phase      = "integration-testing"
  Team       = "backend"
}

# ==============================================================
# Addons Configuration
# ==============================================================
eks_addons = {
  aws-ebs-csi-driver = {
    version                   = "v1.63.0-eksbuild.1"
    service_account_role_name = "test-test-eks-cluster-new-ebs-csi-controller-role"
  }
  vpc-cni = {
    version = "v1.19.2-eksbuild.1"
  }
  coredns = {
    version = "v1.11.4-eksbuild.24"
  }
  kube-proxy = {}
}

# --------------------------------------------------------------
# KMS Variable Fallback
# --------------------------------------------------------------
kms_key_arn = ""

# ==============================================================
# AWS Load Balancer Controller Configuration
# ==============================================================

# Enable the controller
enable_aws_load_balancer_controller = true

# Cost optimization for TEST: Only run 1 replica instead of 2
lb_controller_replica_count         = 1

# Lock the Helm chart version to ensure stability
lb_controller_chart_version         = "1.7.1"

# Feature toggles for ALB protections (Disabled in Test to save money)
enable_waf                          = false
enable_wafv2                        = false
enable_shield                       = false
