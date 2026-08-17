# ==============================================================
# TEST Environment - Complete Enterprise Architecture Stack
# ==============================================================
# Location: environments/test/main.tf

# ------------------------------------------------------------
# 1. KMS Modules (Isolated Encryption Keys per Service)
# ------------------------------------------------------------
module "kms_s3" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "s3"
  description  = "KMS key for S3 bucket encryption in Test"
}

module "kms_secrets" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "secrets-manager"
  description  = "KMS key for Secrets Manager encryption in Test"
}


# ------------------------------------------------------------
# 2. VPC Module (Multi-VPC Networking)
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
}

# ------------------------------------------------------------
# 2.5. VPC Endpoints Module (Decoupled)
# ------------------------------------------------------------
module "vpc_endpoints" {
  source = "../../modules/foundation/vpc-endpoints"

  project_name                = var.project_name
  environment                 = var.environment
  owner                       = var.owner
  aws_region                  = var.aws_region

  vpc_configs                 = var.vpc_configs
  public_route_table_configs  = var.public_route_table_configs
  private_route_table_configs = var.private_route_table_configs
  private_subnet_configs      = var.private_subnet_configs

  vpc_ids                     = module.vpc.vpc_ids
  public_route_table_ids      = module.vpc.public_route_table_ids
  private_route_table_ids     = module.vpc.private_route_table_ids
  private_subnet_ids          = module.vpc.private_subnet_ids

  enable_s3_endpoint          = var.enable_s3_endpoint
  enable_dynamodb_endpoint    = var.enable_dynamodb_endpoint
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
source = "../../modules/foundation/s3"
project_name = var.project_name
environment = var.environment
owner = var.owner
kms_key_arn = module.kms_s3.key_arn
buckets = {
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

# ------------------------------------------------------------
# 6. EKS Module (Enterprise Kubernetes Cluster with Karpenter)
# ------------------------------------------------------------
module "eks" {
  source = "../../modules/runtime/eks"

  # Cluster Identity
  environment     = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Enable the public endpoint so Terraform can reach the cluster
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Network (Using private_subnet_ids exclusively)
  vpc_id             = module.vpc.vpc_ids["vpc-test-web"]
  private_subnet_ids = [
    module.vpc.private_subnet_ids["test-priv-1a"],
    module.vpc.private_subnet_ids["test-priv-1b"],
    module.vpc.private_subnet_ids["test-priv-1c"]
  ]
  # ============================================================
  # Bootstrap Nodes for Karpenter
  # ============================================================
  node_groups = {
    bootstrap = {
      name           = "bootstrap-nodes"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      # Ensure these deploy into your private subnets
      subnet_ids     = [
        module.vpc.private_subnet_ids["test-priv-1a"],
        module.vpc.private_subnet_ids["test-priv-1b"]
      ]
    }
  }
  # ============================================================

  # KMS & Auth
  kms_key_arn            = module.kms_secrets.key_arn
  kms_key_administrators = var.kms_key_administrators
  aws_auth_roles         = var.aws_auth_roles
  aws_auth_users         = []

  # Addons & Feature Toggles
  enable_karpenter                    = false
  enable_cluster_autoscaler           = true
  enable_ebs_csi_driver               = true
  enable_efs_csi_driver               = false
  enable_vpc_cni                      = true
  enable_coredns                      = true
  enable_kube_proxy                   = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  enable_cert_manager                 = true
  enable_metrics_server               = true
  enable_aws_node_termination_handler = true
  enable_container_insights           = true
  enable_prometheus                   = false

  # DNS
  route53_zone_id   = var.route53_zone_id
  route53_zone_name = var.route53_zone_name

  # Tags
  tags       = local.common_tags
  extra_tags = local.environment_tags
}

# ------------------------------------------------------------
# 7. ECR Module (Container Image Registry)
# ------------------------------------------------------------
module "ecr_registry" {
  source       = "../../modules/runtime/ecr"
  environment  = var.environment
  repositories = var.repositories
  extra_tags   = local.environment_tags
}

# ------------------------------------------------------------
# 8. RDS Module (Enterprise Database Instance)
# ------------------------------------------------------------
module "rds" {
  source = "../../modules/runtime/rds"

  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region

  # ✅ Updated to use environment_tags (includes the AutoCleanup tag)
  additional_tags = local.environment_tags

  # Database VPC Isolation
  vpc_id     = module.vpc.vpc_ids["vpc-test-db"]
  subnet_ids = [
    module.vpc.private_subnet_ids["test-db-priv-1a"],
    module.vpc.private_subnet_ids["test-db-priv-1b"],
    module.vpc.private_subnet_ids["test-db-priv-1c"]
  ]
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids

  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type

  # ✅ Updated to use local overrides for cost/testing
  multi_az            = local.multi_az
  publicly_accessible = false

  storage_encrypted        = true
  create_kms_key           = true
  kms_key_deletion_window  = 7
  kms_key_rotation_enabled = true

  # ✅ Updated to use local backup rules
  backup_retention_period = local.backup_retention_period
  skip_final_snapshot     = local.skip_final_snapshot
  copy_tags_to_snapshot   = true

  # ✅ Updated to use local deletion rules
  deletion_protection = local.deletion_protection
  apply_immediately   = true

  create_parameter_group = true
  # ✅ Updated to concat your custom postgres parameters
  db_parameters          = local.db_parameters

  monitoring_interval                   = 0
  create_monitoring_role                = false
  performance_insights_enabled          = false
  # ✅ Updated to use local insights retention
  performance_insights_retention_period = local.performance_insights_retention_period
  create_cloudwatch_alarms              = false
  alarm_actions                         = []

  # ✅ Updated to use local relaxed test thresholds
  cpu_utilization_threshold      = local.cpu_utilization_threshold
  free_storage_space_threshold   = local.free_storage_space_threshold
  freeable_memory_threshold      = local.freeable_memory_threshold
  database_connections_threshold = local.database_connections_threshold

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
}
