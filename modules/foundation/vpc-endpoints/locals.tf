# ==============================================================
# Local Variables
# ==============================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Module      = "vpc-endpoints"
  }

  # Flatten the Interface Endpoints list (Matrix of VPCs x Services)
  vpc_ie_map = {
    for item in flatten([
      for vpc_key, _ in var.vpc_configs : [
        for svc in var.interface_endpoint_services : {
          key          = "${vpc_key}-${svc}"
          vpc_key      = vpc_key
          service_name = svc
        }
      ]
    ]) : item.key => item
  }
}