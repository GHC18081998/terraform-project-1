# ==============================================================================
# Local Variables
# ==============================================================================

locals {
  #-------------------------------------------------------
  # Common Naming
  #-------------------------------------------------------
  name_prefix = "${var.project_name}-${var.environment}"

  # IAM Role and Policy Names (Falls back to variables instead of hardcoded strings)
  iam_role_name   = var.iam_role_name != "" ? var.iam_role_name : "${local.name_prefix}-${var.lb_controller_iam_role_suffix}"
  iam_policy_name = var.iam_policy_name != "" ? var.iam_policy_name : "${local.name_prefix}-${var.lb_controller_iam_policy_suffix}"

  #-------------------------------------------------------
  # OIDC Configuration
  #-------------------------------------------------------
  # FIX: These now use 'var.' instead of 'data.' to fix the cluster dependency!
  oidc_provider_url = var.oidc_provider_url
  oidc_provider_arn = var.oidc_provider_arn

  # Extract the OIDC provider ID (without https://) for IAM Trust Policies
  oidc_provider_id = replace(local.oidc_provider_url, "https://", "")

  #-------------------------------------------------------
  # Service Account Configuration
  #-------------------------------------------------------
  service_account_name      = var.lb_controller_service_account
  service_account_namespace = var.lb_controller_namespace

  # Full service account reference for IRSA
  service_account_full_name = "system:serviceaccount:${local.service_account_namespace}:${local.service_account_name}"

  # Annotation keys declared here to safely pass into Helm's yamlencode()
  lb_controller_role_arn_key     = "eks.amazonaws.com/role-arn"
  lb_controller_sts_endpoint_key = "eks.amazonaws.com/sts-regional-endpoints"

  #-------------------------------------------------------
  # Helm Chart Configuration (Driven by variables)
  #-------------------------------------------------------
  helm_release_name = var.lb_controller_helm_release_name
  helm_repository   = var.lb_controller_helm_repo
  helm_chart        = var.lb_controller_helm_chart

  #-------------------------------------------------------
  # Common Tags
  #-------------------------------------------------------
  common_tags = merge(
    {
      Name        = local.name_prefix
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = var.managed_by_tag
      Component   = var.lb_controller_component_tag
    },
    var.additional_tags
  )

  #-------------------------------------------------------
  # AWS Account Info
  #-------------------------------------------------------
  account_id = data.aws_caller_identity.current.account_id

  aws_region = var.aws_region
}
