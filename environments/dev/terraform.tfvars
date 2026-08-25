# ==============================================================
# DEV Environment Configuration - Single VPC (4 Subnets)
# ==============================================================

aws_region   = "us-east-1"
project_name = "myproject"
environment  = "dev"
owner        = "aws-devops-team"

# --------------------------------------------------------------
# 1 VPC
# --------------------------------------------------------------
vpc_configs = {
  "vpc-dev" = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
  }
}

# --------------------------------------------------------------
# 2 Public Subnets (Multi-AZ)
# --------------------------------------------------------------
public_subnet_configs = {
  "dev-pub-1a" = { vpc_key = "vpc-dev", cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a", map_public_ip = true }
  "dev-pub-1b" = { vpc_key = "vpc-dev", cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b", map_public_ip = true }
}

# --------------------------------------------------------------
# 2 Private Subnets (Multi-AZ)
# --------------------------------------------------------------
private_subnet_configs = {
  "dev-priv-1a" = { vpc_key = "vpc-dev", cidr_block = "10.0.10.0/24", availability_zone = "us-east-1a", subnet_type = "app" }
  "dev-priv-1b" = { vpc_key = "vpc-dev", cidr_block = "10.0.11.0/24", availability_zone = "us-east-1b", subnet_type = "app" }
}

# --------------------------------------------------------------
# 1 NAT Gateway
# --------------------------------------------------------------
nat_gateway_configs = {
  "dev-nat-1a" = { public_subnet_key = "dev-pub-1a" }
}

# --------------------------------------------------------------
# 1 Public Route Table
# --------------------------------------------------------------
public_route_table_configs = {
  "dev-pub-rt" = {
    vpc_key                   = "vpc-dev"
    igw_key                   = "vpc-dev"
    associated_public_subnets = ["dev-pub-1a", "dev-pub-1b"]
  }
}

# --------------------------------------------------------------
# 1 Private Route Table
# --------------------------------------------------------------
private_route_table_configs = {
  "dev-priv-rt" = {
    vpc_key                    = "vpc-dev"
    nat_gateway_key            = "dev-nat-1a"
    associated_private_subnets = ["dev-priv-1a", "dev-priv-1b"]
  }
}

# --------------------------------------------------------------
# S3 Buckets Configuration
# --------------------------------------------------------------
buckets = {
  "app-assets" = {
    versioning_enabled          = true
    intelligent_tiering_enabled = true
  }
  "app-logs" = {
    versioning_enabled = false
    expiration_days    = 90
  }
  # --- HOW TO SCALE OUT or horizontal scaling (Just add these blocks) ---
  "app-user-uploads" = {
    versioning_enabled          = true
    intelligent_tiering_enabled = true 
  }
  "app-db-backups" = {
    versioning_enabled = true
    expiration_days    = 365 # Keep backups for 1 year, then auto-delete
  }
  "app-analytics-data" = {
    versioning_enabled = false
    # Could add a transition rule here in the future
  }
}

# --------------------------------------------------------------
# Secrets Manager Configuration
# --------------------------------------------------------------
secrets = {
  "database-credentials" = {
    description   = "Primary database credentials"
    secret_string = "{\"username\":\"dbadmin\",\"password\":\"changeme\"}"
  }
}

# --------------------------------------------------------------
# IAM Roles & Custom Policies
# --------------------------------------------------------------
iam_roles = {
  "ec2-app-role" = {
    description = "Role for EC2 application servers"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    })
  }
}

iam_policies = {
  "s3-full-access" = {
    description = "Provides full access to all S3 buckets"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:*"]
          Resource = "*"
        }
      ]
    })
  }
  
  "dynamodb-full-access" = {
    description = "Provides full access to all DynamoDB tables"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["dynamodb:*"]
          Resource = "*"
        }
      ]
    })
  }
}
  
  # Custom policies for GitHub Actions to build infrastructure
"TerraformIAMBuilderPolicy" = {
    description = "Allows Terraform to manage IAM Roles and Instance Profiles"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "TerraformIAMManagement"
          Effect = "Allow"
          Action = [
            "iam:CreateRole",
            "iam:GetRole",
            "iam:DeleteRole",
            "iam:ListRoleTags",
            "iam:TagRole",
            "iam:UntagRole",
            "iam:ListRolePolicies",
            "iam:GetRolePolicy",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:CreateInstanceProfile",
            "iam:GetInstanceProfile",
            "iam:DeleteInstanceProfile",
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:PassRole",
            "iam:ListInstanceProfilesForRole"
          ]
          Resource = "*"
        }
      ]
    })
  }

  "AllowEIPManagement" = {
    description = "Allows Terraform to manage Elastic IPs for NAT Gateways"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:AllocateAddress",
            "ec2:ReleaseAddress",
            "ec2:DescribeAddresses",
            "ec2:AssociateAddress",
            "ec2:DisassociateAddress"
          ]
          Resource = "*"
        }
      ]
    })
  }

  "kms-key-policy" = {
    description = "Allows Terraform to manage KMS keys for state encryption"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "kms:CreateKey",
            "kms:ListKeys",
            "kms:ListAliases",
            "kms:DescribeKey",
            "kms:CreateAlias",
            "kms:DeleteAlias",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion",
            "kms:PutKeyPolicy",
            "kms:GetKeyPolicy",
            "kms:EnableKeyRotation",
            "kms:TagResource",
            "kms:UntagResource"
          ]
          Resource = "*"
        }
      ]
    })
  }


iam_role_policy_attachments = {
  "ec2_s3_attach" = {
    role   = "ec2-app-role"
    policy = "s3-full-access" 
  }
  "ec2_dynamodb_attach" = {
    role   = "ec2-app-role"
    policy = "dynamodb-full-access"
  }
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
    description = "Role assumed by GitHub Actions via OIDC"
    # REMEMBER TO UPDATE: YOUR_AWS_ACCOUNT_ID, YOUR_GITHUB_ORG, YOUR_REPO_NAME
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = "arn:aws:iam::274089075418:oidc-provider/token.actions.githubusercontent.com"
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:GHC18081998/project-1-terraform:*"
            }
          }
        }
      ]
    })
  }
}

# --------------------------------------------------------------
# OIDC Role Policy Attachments (All 9 policies)
# --------------------------------------------------------------
iam_oidc_role_policy_attachments = {
  
  # --- 3 Customer Managed Policies (Defined in iam_policies above) ---
  "attach_custom_iam" = {
    role   = "github-deploy-role"
    policy = "TerraformIAMBuilderPolicy"
  }
  "attach_custom_eip" = {
    role   = "github-deploy-role"
    policy = "AllowEIPManagement"
  }
  "attach_custom_kms" = {
    role   = "github-deploy-role"
    policy = "kms-key-policy"
  }

  # --- 6 AWS Managed Policies (Using official AWS ARNs) ---
  "attach_aws_dynamodb" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  }
  "attach_aws_ec2" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  }
  "attach_aws_s3" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  "attach_aws_vpc" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  }
  "attach_aws_kms_power" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  }
  "attach_aws_iam_readonly" = {
    role   = "github-deploy-role"
    policy = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  }
}