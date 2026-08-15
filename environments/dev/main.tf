# ==============================================================
# DEV Environment - Complete Enterprise Architecture Stack
# ==============================================================
# Location: terraform/networking/environments/dev/main.tf

# ------------------------------------------------------------
# 1. KMS Modules (Isolated Encryption Keys per Service)
# ------------------------------------------------------------
module "kms_s3" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "s3"
  description  = "KMS key for S3 bucket encryption"
}

module "kms_secrets" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "secrets-manager"
  description  = "KMS key for Secrets Manager encryption"
}

# ------------------------------------------------------------
# 2. VPC Module (Multi-VPC Networking & Endpoints)
# ------------------------------------------------------------
module "vpc" {
  source                      = "../../modules/foundation/vpc"
  project_name                = var.project_name
  environment                 = var.environment
  owner                       = var.owner
  aws_region                  = var.aws_region
  vpc_configs                 = var.vpc_configs
  public_subnet_configs       = var.public_subnet_configs
  private_subnet_configs      = var.private_subnet_configs
  public_route_table_configs  = var.public_route_table_configs
  private_route_table_configs = var.private_route_table_configs
  nat_gateway_configs         = var.nat_gateway_configs
  interface_endpoint_services = var.interface_endpoint_services
}

# ------------------------------------------------------------
# 3. IAM Module (Enterprise Roles, Policies, & OIDC)
# ------------------------------------------------------------
module "iam" {
  source                       = "../../modules/foundation/iam"
  project_name                 = var.project_name
  environment                  = var.environment
  owner                        = var.owner
  roles                        = var.iam_roles
  policies                     = var.iam_policies
  role_policy_attachments      = var.iam_role_policy_attachments
  oidc_providers               = var.iam_oidc_providers
  oidc_roles                   = var.iam_oidc_roles
  oidc_role_policy_attachments = var.iam_oidc_role_policy_attachments
}

# ------------------------------------------------------------
# 4. S3 Module (Secure Buckets with Dedicated KMS)
# ------------------------------------------------------------
module "s3" {
  source       = "../../modules/foundation/s3"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  kms_key_arn  = module.kms_s3.key_arn
  buckets      = {
    "app-assets" = {
      versioning_enabled = true
      # You do not need to specify bucket_name, your module auto-generates it!
    }

    # You can also add your state bucket here so the module builds it!
    "terraform-state" = {
      versioning_enabled = true
    }
  }
}

# ------------------------------------------------------------
# 5. Secrets Manager Module (Encrypted Secrets with Dedicated KMS)
# ------------------------------------------------------------
module "secrets_manager" {
  source       = "../../modules/foundation/secrets-manager"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  kms_key_arn  = module.kms_secrets.key_arn
  secrets      = var.secrets
}
