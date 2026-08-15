# ==============================================================
# NAT Gateway Module
# Creates Elastic IPs and NAT Gateways for private subnets
# ==============================================================

# Elastic IP for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.nat_gateway_configs

  domain = "vpc"

  tags = merge(local.common_tags, each.value.tags, {
    Name           = "${var.project_name}-${var.environment}-${each.key}-nat-eip"
    NATGatewayName = each.key
  })
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateway_configs

  allocation_id     = aws_eip.nat[each.key].id
  subnet_id         = aws_subnet.public[each.value.public_subnet_key].id
  connectivity_type = "public"

  tags = merge(local.common_tags, each.value.tags, {
    Name             = "${var.project_name}-${var.environment}-${each.key}-ngw"
    PublicSubnetKey  = each.value.public_subnet_key
  })

  depends_on = [aws_eip.nat]
}