# ==============================================================
# Private Subnet Module
# Supports multiple private subnet types: app, data, eks
# Automatically attached to correct VPC
# ==============================================================

resource "aws_subnet" "private" {
  for_each = var.private_subnet_configs

  vpc_id                  = aws_vpc.this[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name       = "${var.project_name}-${var.environment}-${each.key}-private-subnet"
      VPCKey     = each.value.vpc_key
      Type       = "private"
      SubnetRole = each.value.subnet_type
    }
  )
}