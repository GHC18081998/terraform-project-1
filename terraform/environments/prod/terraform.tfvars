# ==============================================================
# prod Environment Configuration
# ==============================================================
# Location: environments/prod/terraform.tfvars

aws_region   = "us-east-1"
project_name = "myproject"
environment  = "prod"
owner        = "aws-devops-team"
account_id   = "123456789012"

# --------------------------------------------------------------
# EXACTLY 2 VPCs (Web and Database)
# --------------------------------------------------------------
vpc_configs = {
  "vpc-prod-web" = { cidr_block = "10.20.0.0/16", enable_dns_hostnames = true, enable_dns_support = true }
  "vpc-prod-db"  = { cidr_block = "10.21.0.0/16", enable_dns_hostnames = true, enable_dns_support = true }
}

# --------------------------------------------------------------
# EXACTLY 6 SUBNETS TOTAL (3 Public, 3 Private)
# --------------------------------------------------------------
public_subnet_configs = {
  "prod-web-pub-1a" = { vpc_key = "vpc-prod-web", cidr_block = "10.20.1.0/24", availability_zone = "us-east-1a", map_public_ip = true }
  "prod-web-pub-1b" = { vpc_key = "vpc-prod-web", cidr_block = "10.20.2.0/24", availability_zone = "us-east-1b", map_public_ip = true }
  "prod-web-pub-1c" = { vpc_key = "vpc-prod-web", cidr_block = "10.20.3.0/24", availability_zone = "us-east-1c", map_public_ip = true }
}

private_subnet_configs = {
  "prod-priv-1a"    = { vpc_key = "vpc-prod-web", cidr_block = "10.20.10.0/24", availability_zone = "us-east-1a", subnet_type = "app" }
  "prod-priv-1b"    = { vpc_key = "vpc-prod-web", cidr_block = "10.20.11.0/24", availability_zone = "us-east-1b", subnet_type = "app" }
  "prod-priv-1c"    = { vpc_key = "vpc-prod-web", cidr_block = "10.20.12.0/24", availability_zone = "us-east-1c", subnet_type = "app" }
  # DB Subnets (Generated within vpc-prod-db)
  "prod-db-priv-1a" = { vpc_key = "vpc-prod-db", cidr_block = "10.21.10.0/24", availability_zone = "us-east-1a", subnet_type = "db" }
  "prod-db-priv-1b" = { vpc_key = "vpc-prod-db", cidr_block = "10.21.11.0/24", availability_zone = "us-east-1b", subnet_type = "db" }
  "prod-db-priv-1c" = { vpc_key = "vpc-prod-db", cidr_block = "10.21.12.0/24", availability_zone = "us-east-1c", subnet_type = "db" }
}

# --------------------------------------------------------------
# EXACTLY 1 NAT GATEWAY
# --------------------------------------------------------------
nat_gateway_configs = {
  "prod-nat-1" = { public_subnet_key = "prod-web-pub-1a" }
}

# --------------------------------------------------------------
# EXACTLY 2 ROUTE TABLES (1 per VPC)
# --------------------------------------------------------------
public_route_table_configs = {
  "prod-web-pub-rt" = { 
    vpc_key                     = "vpc-prod-web"
    igw_key                     = "vpc-prod-web" 
    associated_public_subnets = ["prod-web-pub-1a", "prod-web-pub-1b", "prod-web-pub-1c"] 
  }
}

private_route_table_configs = {
  "prod-priv-rt" = { 
    vpc_key                    = "vpc-prod-web"
    nat_gateway_key            = "prod-nat-1"
    associated_private_subnets = ["prod-priv-1a", "prod-priv-1b", "prod-priv-1c"]
  }
  "prod-db-rt" = {
    vpc_key                    = "vpc-prod-db"
    associated_private_subnets = ["prod-db-priv-1a", "prod-db-priv-1b", "prod-db-priv-1c"]
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
cluster_name           = "prod-eks-cluster"
cluster_version        = "1.31"
kms_key_administrators = [
  "arn:aws:iam::482112738265:role/AdminRole",
]

# Karpenter NodePools configuration for Production
node_pools = {
  general = {
    instance_families    = ["m5", "m6i", "c6i", "r6i"]
    instance_sizes       = ["large", "xlarge", "2xlarge"]
    capacity_types       = ["spot", "on-demand"]
    arch                 = ["amd64"]
    ami_family           = "AL2023"
    min_cpu              = "4"
    max_cpu              = "500"
    min_memory           = "16Gi"
    max_memory           = "2000Gi"
    labels               = { "workload-type" = "production-general" }
    taints               = []
    consolidation_policy = "WhenUnderutilized"
    expire_after         = "720h"
  }
}

# ==========================================
# Bootstrap Nodes for Karpenter
# ==========================================
node_groups = {
  bootstrap = {
    name           = "prod-bootstrap-nodes"
    instance_types = ["t3.medium"]
    min_size       = 2
    max_size       = 3
    desired_size   = 2
  }
}

# --------------------------------------------------------------
# S3 Buckets Configuration
# --------------------------------------------------------------
s3_buckets = { 
  "app-assets" = {
    versioning_enabled          = true
    intelligent_tiering_enabled = true
  }
  "app-logs" = {
    versioning_enabled = false
    expiration_days    = 120
  }
  "app-user-uploads" = {
    versioning_enabled          = true
    intelligent_tiering_enabled = true 
  }
  "app-db-backups" = {
    versioning_enabled = true
    expiration_days    = 365
  }
  "app-analytics-data" = {
    versioning_enabled = false
  }
}

# --------------------------------------------------------------
# Secrets Manager Configuration
# --------------------------------------------------------------
secrets = {
  "database-credentials-prod-v2" = {
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
  frontend = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["dev-", "rc-"]
  }

  backend = {
    image_tag_mutability       = "MUTABLE"
    scan_on_push               = true
    untagged_image_expiry_days = 3
    tagged_image_max_count     = 10
    tagged_prefixes            = ["dev-", "rc-"]
  }
}

# --------------------------------------------------------------
# Database Configuration (RDS)
# --------------------------------------------------------------
db_name     = "appdb"
db_username = "dbadmin"
db_password = "" 

engine         = "postgres"
engine_version = "15.7"

instance_class        = "db.t3.medium"
allocated_storage     = 20
max_allocated_storage = 50
storage_type          = "gp3"

backup_retention_period = 3
monitoring_interval     = 60
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
# Route53 DNS Configuration
# --------------------------------------------------------------
route53_zone_id   = "Z1234567890ABCDEFGHIJ"
route53_zone_name = "prod.example.com"

# --------------------------------------------------------------
# Additional IAM roles for cluster access (aws-auth)
# --------------------------------------------------------------
aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::123456789012:role/ProdAdminRole"
    username = "prod-admin"
    groups   = ["system:masters"]
  },
]

# --------------------------------------------------------------
# Global Extra Tags
# --------------------------------------------------------------
extra_tags = {
  CostCenter = "engineering-prod"
  Owner      = "aws-devops-team"
  Phase      = "production"
  Team       = "backend"
}