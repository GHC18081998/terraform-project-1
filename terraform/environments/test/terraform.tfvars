# ==============================================================
# TEST Environment Configuration
# ==============================================================
# Location: environments/test/terraform.tfvars

aws_region   = "us-east-1"
project_name = "myproject"
environment  = "test"
owner        = "aws-devops-team"
account_id   = "482112738265"

# --------------------------------------------------------------
# EXACTLY 2 VPCs (Web and Database)
# --------------------------------------------------------------
vpc_configs = {
  "vpc-test-web" = { cidr_block = "10.20.0.0/16", enable_dns_hostnames = true, enable_dns_support = true }
  "vpc-test-db"  = { cidr_block = "10.21.0.0/16", enable_dns_hostnames = true, enable_dns_support = true }
}

# --------------------------------------------------------------
# EXACTLY 6 SUBNETS TOTAL (3 Public, 3 Private)
# --------------------------------------------------------------
public_subnet_configs = {
  "test-web-pub-1a" = { vpc_key = "vpc-test-web", cidr_block = "10.20.1.0/24", availability_zone = "us-east-1a", map_public_ip = true }
  "test-web-pub-1b" = { vpc_key = "vpc-test-web", cidr_block = "10.20.2.0/24", availability_zone = "us-east-1b", map_public_ip = true }
  "test-web-pub-1c" = { vpc_key = "vpc-test-web", cidr_block = "10.20.3.0/24", availability_zone = "us-east-1c", map_public_ip = true }
}

private_subnet_configs = {
  "test-priv-1a"    = { vpc_key = "vpc-test-web", cidr_block = "10.20.10.0/24", availability_zone = "us-east-1a", subnet_type = "app" }
  "test-priv-1b"    = { vpc_key = "vpc-test-web", cidr_block = "10.20.11.0/24", availability_zone = "us-east-1b", subnet_type = "app" }
  "test-priv-1c"    = { vpc_key = "vpc-test-web", cidr_block = "10.20.12.0/24", availability_zone = "us-east-1c", subnet_type = "app" }
  # DB Subnets (Generated within vpc-test-db)
  "test-db-priv-1a" = { vpc_key = "vpc-test-db", cidr_block = "10.21.10.0/24", availability_zone = "us-east-1a", subnet_type = "db" }
  "test-db-priv-1b" = { vpc_key = "vpc-test-db", cidr_block = "10.21.11.0/24", availability_zone = "us-east-1b", subnet_type = "db" }
  "test-db-priv-1c" = { vpc_key = "vpc-test-db", cidr_block = "10.21.12.0/24", availability_zone = "us-east-1c", subnet_type = "db" }
}

# --------------------------------------------------------------
# EXACTLY 1 NAT GATEWAY
# --------------------------------------------------------------
nat_gateway_configs = {
  "test-nat-1" = { public_subnet_key = "test-web-pub-1a" }
}

# --------------------------------------------------------------
# EXACTLY 2 ROUTE TABLES (1 per VPC)
# --------------------------------------------------------------
public_route_table_configs = {
  "test-web-pub-rt" = {
    vpc_key                     = "vpc-test-web"
    igw_key                     = "vpc-test-web"
    associated_public_subnets = ["test-web-pub-1a", "test-web-pub-1b", "test-web-pub-1c"]
  }
}

private_route_table_configs = {
  "test-priv-rt" = {
    vpc_key                    = "vpc-test-web"
    nat_gateway_key            = "test-nat-1"
    associated_private_subnets = ["test-priv-1a", "test-priv-1b", "test-priv-1c"]
  }
  "test-db-rt" = {
    vpc_key                    = "vpc-test-db"
    associated_private_subnets = ["test-db-priv-1a", "test-db-priv-1b", "test-db-priv-1c"]
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
  "arn:aws:iam::482112738265:role/AdminRole",
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
db_name     = "appdb2"
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
# DNS Configuration
# --------------------------------------------------------------
route53_zone_id   = "Z1234567890ABCDEFGHIJ"
route53_zone_name = "test.example.com"

# --------------------------------------------------------------
# Additional IAM roles for cluster access (aws-auth)
# --------------------------------------------------------------
aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::482112738265:role/DevTeamRole"
    username = "devteam"
    groups   = ["system:masters"]
  },
]

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

