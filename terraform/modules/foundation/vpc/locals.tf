locals {

  name_prefix = "${var.project_name}-${var.environment}"

  # ==============================================================
  # Base Tags
  # ==============================================================
  # Shared tags applied to all resources in this network module
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }

  # ==============================================================
  # Resource-Specific Tags
  # ==============================================================
  # Merges the base tags with specific module/type identifiers
  vpc_tags            = merge(local.common_tags, { Module = "vpc" })
  igw_tags            = merge(local.common_tags, { Module = "igw" })
  ngw_tags            = merge(local.common_tags, { Module = "ngw" })
  private_rt_tags     = merge(local.common_tags, { Module = "private-route-table" })
  public_rt_tags      = merge(local.common_tags, { Module = "public-route-table" })

  private_subnet_tags = merge(local.common_tags, {
    Module     = "private-subnet"
    SubnetType = "private"
  })

  public_subnet_tags  = merge(local.common_tags, {
    Module     = "public-subnet"
    SubnetType = "public"
  })

  # ==============================================================
  # Route Table Associations
  # ==============================================================

  # Flatten route table to subnet associations for PRIVATE subnets
  private_rt_subnet_associations = merge([
    for rt_key, rt_config in var.private_route_table_configs : {
      for subnet_key in rt_config.associated_private_subnets :
      "${rt_key}-${subnet_key}" => {
        route_table_key = rt_key
        subnet_key      = subnet_key
      }
    }
  ]...)

  # Flatten route table to subnet associations for PUBLIC subnets
  public_rt_subnet_associations = merge([
    for rt_key, rt_config in var.public_route_table_configs : {
      for subnet_key in rt_config.associated_public_subnets :
      "${rt_key}-${subnet_key}" => {
        route_table_key = rt_key
        subnet_key      = subnet_key
      }
    }
  ]...)

  # ==============================================================
  # VPC Endpoint Groupings
  # ==============================================================

  # Group Private Route Tables by VPC (for S3/DynamoDB Gateways)
  vpc_private_rts = {
    for vpc_key, _ in aws_vpc.this : vpc_key => [
      for rt_key, rt_config in var.private_route_table_configs : aws_route_table.private[rt_key].id
      if rt_config.vpc_key == vpc_key
    ]
  }

  # Group Public Route Tables by VPC (for S3 Gateway)
  vpc_public_rts = {
    for vpc_key, _ in aws_vpc.this : vpc_key => [
      for rt_key, rt_config in var.public_route_table_configs : aws_route_table.public[rt_key].id
      if rt_config.vpc_key == vpc_key
    ]
  }

  # Group Private Subnets by VPC (for Interface Endpoints)
  vpc_private_subnets = {
    for vpc_key, _ in aws_vpc.this : vpc_key => [
      for sub_key, sub_config in var.private_subnet_configs : aws_subnet.private[sub_key].id
      if sub_config.vpc_key == vpc_key
    ]
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
  interface_endpoints = local.vpc_ie_map
}
