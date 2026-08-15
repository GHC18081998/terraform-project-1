# ==============================================================
# VPC Module
# ==============================================================

resource "aws_vpc" "this" {
  for_each = var.vpc_configs

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support
  instance_tenancy     = each.value.instance_tenancy

  tags = merge(local.vpc_tags, each.value.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-vpc"
  })
}
