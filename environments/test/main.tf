# ==============================================================
# TEST Environment - Multi-Region Enterprise Architecture Stack
# Foundation/RDS: us-east-1 | Deployment Tools/EKS: Secondary Region
# ==============================================================
# Location: environments/test/main.tf

# ------------------------------------------------------------
# 1. KMS Modules (Isolated Encryption Keys per Service - us-east-1)
# ------------------------------------------------------------
module "kms_s3" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "s3"
  description  = "KMS key for S3 bucket encryption in ${var.environment}"
}

module "kms_secrets" {
  source       = "../../modules/foundation/kms"
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  key_purpose  = "secrets-manager"
  description  = "KMS key for Secrets Manager encryption in ${var.environment}"
}

# ------------------------------------------------------------
# 2. VPC Module (Foundation & RDS Network - Primary Region)
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
# 2.5. VPC Endpoints Module (Foundation Network)
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
# 3. IAM Module (Global Service)
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

  # Removed hardcoded map; data pulled strictly from tfvars
  buckets = var.s3_buckets
}

# ------------------------------------------------------------
# 5. Secrets Manager Module
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
# 6. EKS Module (Enterprise Kubernetes Cluster - Secondary Region)
# ------------------------------------------------------------
module "eks" {
  source = "../../modules/runtime/eks"

  environment     = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  # Network - Pointed to Tools VPC
  vpc_id             = module.vpc.vpc_ids["main-vpc"]
  private_subnet_ids = [
    module.vpc.private_subnet_ids["main-priv-2a"],
    module.vpc.private_subnet_ids["main-priv-2b"]
  ]

  # Bootstrap Nodes for Karpenter dynamically scaled via variables
  node_groups = {
    bootstrap = {
      name           = "bootstrap-nodes"
      instance_types = var.eks_bootstrap_instance_types
      min_size       = var.eks_bootstrap_min_size
      max_size       = var.eks_bootstrap_max_size
      desired_size   = var.eks_bootstrap_desired_size
      subnet_ids     = [
        module.vpc.private_subnet_ids["main-priv-2a"],
        module.vpc.private_subnet_ids["main-priv-2b"]
      ]
    }
  }

  kms_key_arn            = module.kms_secrets.key_arn
  kms_key_administrators = var.kms_key_administrators
  aws_auth_roles         = var.aws_auth_roles
  aws_auth_users         = var.aws_auth_users

  # Addons & Feature Toggles
  enable_karpenter                    = false
  enable_cluster_autoscaler           = true
  enable_ebs_csi_driver               = true
  enable_efs_csi_driver               = false
  enable_vpc_cni                      = true
  enable_coredns                      = true
  enable_kube_proxy                   = true
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_external_dns                 = true
  enable_cert_manager                 = true
  enable_metrics_server               = true
  enable_aws_node_termination_handler = true
  enable_container_insights           = true
  enable_prometheus                   = false

  route53_zone_id   = var.route53_zone_id
  route53_zone_name = var.route53_zone_name

  tags       = local.common_tags
  extra_tags = local.environment_tags
}

# ------------------------------------------------------------
# 7. ECR Module (Container Image Registry - Secondary Region)
# ------------------------------------------------------------
module "ecr_registry" {
  source       = "../../modules/runtime/ecr"
  environment  = var.environment
  repositories = var.repositories
  extra_tags   = local.environment_tags
}

# ------------------------------------------------------------
# 8. RDS Module (Enterprise Database Instance - Primary Region)
# ------------------------------------------------------------
module "rds" {
  source = "../../modules/runtime/rds"

  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  additional_tags = local.environment_tags

  # Database VPC Isolation (Main Network)
  vpc_id     = module.vpc.vpc_ids["main-vpc"]
  subnet_ids = [
    module.vpc.private_subnet_ids["main-priv-2a"],
    module.vpc.private_subnet_ids["main-priv-2b"]
  ]

  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids

  db_name        = var.db_name
  db_username    = var.db_username
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type

  multi_az            = local.multi_az
  publicly_accessible = false

  storage_encrypted        = true
  create_kms_key           = true
  kms_key_deletion_window  = 7
  kms_key_rotation_enabled = true

  backup_retention_period = local.backup_retention_period
  skip_final_snapshot     = local.skip_final_snapshot
  copy_tags_to_snapshot   = true

  deletion_protection = local.deletion_protection
  apply_immediately   = true

  create_parameter_group = true
  db_parameters          = local.db_parameters

  monitoring_interval                   = var.monitoring_interval
  create_monitoring_role                = false
  performance_insights_enabled          = false
  performance_insights_retention_period = local.performance_insights_retention_period
  create_cloudwatch_alarms              = false
  alarm_actions                         = var.alarm_actions

  cpu_utilization_threshold      = local.cpu_utilization_threshold
  free_storage_space_threshold   = local.free_storage_space_threshold
  freeable_memory_threshold      = local.freeable_memory_threshold
  database_connections_threshold = local.database_connections_threshold

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
}

# ==============================================================================
# 9. AWS Load Balancer Controller Module (Secondary Region)
# ==============================================================================
module "load_balancer_controller" {
  source = "../../modules/runtime/load-balancer-controller"
  
  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  vpc_id       = module.vpc.vpc_ids["main-vpc"]
  cluster_name = module.eks.cluster_name

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# ==============================================================================
# 11. Tools Infrastructure (Shared Access, Jenkins, Nexus, SonarQube)
# ==============================================================================
module "shared_access" {
  source = "../../modules/platform/shared-access"

  vpc_id            = module.vpc.vpc_ids["main-vpc"]
  public_subnet_ids = [
    module.vpc.public_subnet_ids["main-pub-2a"],
    module.vpc.public_subnet_ids["main-pub-2b"]
  ]

  name_prefix = local.name_prefix

  is_internal_alb  = var.shared_is_internal_alb
  is_ebs_encrypted = var.shared_is_ebs_encrypted

  jenkins_hc_path  = var.jenkins_hc_path
  nexus_hc_path    = var.nexus_hc_path
  sonar_hc_path    = var.sonar_hc_path
  sonar_hc_matcher = var.sonar_hc_matcher

  lb_port       = var.lb_port
  jenkins_port  = var.jenkins_port
  nexus_port    = var.nexus_port
  sonar_port    = var.sonar_port
  postgres_port = var.postgres_port

  jenkins_ebs_size = var.jenkins_ebs_size
  jenkins_ebs_type = var.jenkins_ebs_type

  tags = local.environment_tags
}

module "jenkins" {
  source = "../../modules/platform/jenkins"

  subnet_id          = module.vpc.private_subnet_ids["main-priv-2a"]
  security_group_ids = [module.shared_access.jenkins_sg_id]
  target_group_arn   = module.shared_access.jenkins_tg_arn
  ebs_volume_id      = module.shared_access.jenkins_ebs_volume_id

  iam_instance_profile = module.iam.instance_profile_names["ec2-app-role"]

  instance_type  = var.jenkins_instance_type
  java_version   = var.jenkins_java_version
  jenkins_port   = var.jenkins_port

  tags = local.environment_tags
}

module "nexus" {
  source = "../../modules/platform/nexus"

  
  subnet_id            = module.vpc.private_subnet_ids["main-priv-2a"]
  security_group_ids   = [module.shared_access.nexus_sg_id]
  target_group_arn     = module.shared_access.nexus_tg_arn
  iam_instance_profile = module.iam.instance_profile_names["ec2-app-role"]

  instance_type  = var.nexus_instance_type
  nexus_port     = var.nexus_port
  nexus_version  = var.nexus_version
  java_package   = var.nexus_java_package

  tags = local.environment_tags
}

module "sonarqube" {
  source = "../../modules/platform/sonarqube"


  subnet_id            = module.vpc.private_subnet_ids["main-priv-2a"]
  security_group_ids   = [module.shared_access.sonar_sg_id]
  target_group_arn     = module.shared_access.sonar_tg_arn
  iam_instance_profile = module.iam.instance_profile_names["ec2-app-role"]

  project_name = var.project_name
  environment  = var.environment
  db_username  = var.sonarqube_db_username

  instance_type      = var.sonarqube_instance_type
  sonarqube_version  = var.sonarqube_version
  java_version       = var.sonarqube_java_version
  postgres_version   = var.sonarqube_postgres_version

  sonarqube_port = var.sonar_port
  db_port        = var.postgres_port

  sonar_password_length           = var.sonar_password_length
  sonar_password_special          = var.sonar_password_special
  sonar_password_override_special = var.sonar_password_override_special

  ebs_volume_size             = var.sonarqube_ebs_size
  ebs_volume_type             = var.sonarqube_ebs_type
  ebs_encrypted               = var.sonarqube_ebs_encrypted
  ebs_delete_on_termination   = var.sonarqube_ebs_delete_on_termination

  sonarqube_data_volume_size      = var.sonarqube_data_ebs_size
  sonarqube_data_volume_type      = var.sonarqube_data_ebs_type
  sonarqube_data_volume_encrypted = var.sonarqube_data_encrypted
  sonarqube_data_device_name      = var.sonarqube_data_device_name
  sonarqube_data_prevent_destroy  = false

  postgres_volume_size            = var.postgres_volume_size
  postgres_volume_type            = var.postgres_volume_type
  postgres_volume_encrypted       = var.postgres_volume_encrypted
  postgres_device_name            = var.postgres_device_name
  postgres_volume_prevent_destroy = false

  aws_region = var.aws_region

  secret_id = module.rds.db_secret_arn
  secret_recovery_window_in_days = var.secret_recovery_window_in_days

  sonar_image          = var.sonarqube_docker_image
  sonar_host_port      = var.sonar_host_port
  sonar_container_port = var.sonar_container_port
  sonar_container_name = var.sonar_container_name
  docker_repo_url      = var.docker_repo_url
  docker_package       = var.docker_package

  s3_backup_bucket = module.s3.bucket_ids["app-db-backups"]

  tags = local.environment_tags
}

module "sonarqube_secrets" {
  source = "../../modules/foundation/secrets-manager"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  kms_key_arn  = null
  secrets      = var.secrets
}
