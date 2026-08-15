# ==============================================================
# Public Subnet Module
# Creates subnets and attaches to correct VPC automatically
# Supports multiple subnets per VPC
# ==============================================================

resource "aws_subnet" "public" {
  for_each = var.public_subnet_configs

  vpc_id                  = aws_vpc.this[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name    = "${var.project_name}-${var.environment}-${each.key}-public-subnet"
      VPCKey  = each.value.vpc_key
      Type    = "public"
    }
  )
}