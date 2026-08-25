# ==============================================================
# PROD Environment - Complete Enterprise Architecture Stack
# ==============================================================
# Location: environments/prod/main.tf

# ------------------------------------------------------------
# 1. KMS Modules (Isolated Encryption Keys per Service)
# ------------------------------------------------------------
module "kms_s3" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "s3"
  description  = "KMS key for S3 bucket encryption in Prod"
}

module "kms_secrets" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "secrets-manager"
  description  = "KMS key for Secrets Manager encryption in Prod"
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
# 3. S3 Module (Secure Buckets with Dedicated KMS)
# ------------------------------------------------------------
module "s3" {
  source       = "../../modules/foundation/s3"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  kms_key_arn  = module.kms_s3.key_arn
  buckets      = var.s3_buckets
}

# ------------------------------------------------------------
# 4. Secrets Manager Module (Encrypted Secrets with Dedicated KMS)
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
# 5. EKS Module (Enterprise Kubernetes Cluster with Karpenter)
# ------------------------------------------------------------
module "eks" {
  source = "../../modules/runtime/eks"

  environment     = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Production security: Keep the endpoint private
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  cluster_endpoint_private_access = true

  vpc_id             = module.vpc.vpc_ids["vpc-prod-web"] # Adjust to match your prod VPC key
  private_subnet_ids = [
    module.vpc.private_subnet_ids["prod-priv-1a"],
    module.vpc.private_subnet_ids["prod-priv-1b"],
    module.vpc.private_subnet_ids["prod-priv-1c"]
  ]

  node_groups = var.node_groups
  node_pools  = var.node_pools

  kms_key_arn            = module.kms_secrets.key_arn
  kms_key_administrators = var.kms_key_administrators
  aws_auth_roles         = var.aws_auth_roles
  aws_auth_users         = []

  enable_karpenter                    = true
  enable_ebs_csi_driver               = true
  enable_vpc_cni                      = true
  enable_coredns                      = true
  enable_kube_proxy                   = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  enable_cert_manager                 = true
  enable_metrics_server               = true
  enable_aws_node_termination_handler = true
  enable_container_insights           = true

  route53_zone_id   = var.route53_zone_id
  route53_zone_name = var.route53_zone_name

  tags       = local.common_tags
  extra_tags = local.environment_tags
}

# ------------------------------------------------------------
# 6. ECR Module (Container Image Registry)
# ------------------------------------------------------------
module "ecr_registry" {
  source       = "../../modules/runtime/ecr"
  environment  = var.environment
  repositories = var.repositories
  extra_tags   = local.environment_tags
}

# ------------------------------------------------------------
# 7. RDS Module (Enterprise Database Instance)
# ------------------------------------------------------------
module "rds" {
  source = "../../modules/runtime/rds"

  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  additional_tags = local.common_tags

  vpc_id     = module.vpc.vpc_ids["vpc-prod-db"] # Adjust to match your prod DB VPC key
  subnet_ids = [
    module.vpc.private_subnet_ids["prod-db-priv-1a"],
    module.vpc.private_subnet_ids["prod-db-priv-1b"],
    module.vpc.private_subnet_ids["prod-db-priv-1c"]
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

  multi_az            = true # Production best practice
  publicly_accessible = false

  storage_encrypted          = true
  create_kms_key             = true
  kms_key_deletion_window    = 30 # Longer window for production
  kms_key_rotation_enabled   = true

  backup_retention_period    = 30 # Production backup retention
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = true

  deletion_protection        = false # Production safety
  apply_immediately          = false

  create_parameter_group     = true
  db_parameters              = var.db_parameters

  monitoring_interval                    = 60
  create_monitoring_role                 = true
  performance_insights_enabled           = true
  performance_insights_retention_period  = 7
  create_cloudwatch_alarms               = true
  alarm_actions                          = []

  cpu_utilization_threshold      = 80
  free_storage_space_threshold   = 5000000000
  freeable_memory_threshold      = 256000000
  database_connections_threshold = 100

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
}
