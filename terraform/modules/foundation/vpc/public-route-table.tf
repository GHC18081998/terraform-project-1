# ==============================================================
# Public Route Table Module
# Creates route tables with IGW routes
# Automatically associates with public subnets
# ==============================================================

# Public Route Tables
resource "aws_route_table" "public" {
  for_each = var.public_route_table_configs

  vpc_id = aws_vpc.this[each.value.vpc_key].id

  # Default route to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[each.value.igw_key].id
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name   = "${var.project_name}-${var.environment}-${each.key}-public-rt"
    VPCKey = each.value.vpc_key
    IGWKey = each.value.igw_key
    Type   = "public"
  })
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "public" {
  for_each = local.public_rt_subnet_associations

  subnet_id      = aws_subnet.public[each.value.subnet_key].id
  route_table_id = aws_route_table.public[each.value.route_table_key].id
}