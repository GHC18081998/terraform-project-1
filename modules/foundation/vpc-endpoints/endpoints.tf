# ==============================================================
# Gateway Endpoints (S3 & DynamoDB)
# ==============================================================

resource "aws_vpc_endpoint" "s3" {
  for_each          = var.enable_s3_endpoint ? var.vpc_configs : {}

  vpc_id            = var.vpc_ids[each.key]
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Dynamically filters and attaches ALL route tables that belong to THIS specific VPC
  route_table_ids = concat(
    [for rt_key, rt in var.private_route_table_configs : var.private_route_table_ids[rt_key] if rt.vpc_key == each.key],
    [for rt_key, rt in var.public_route_table_configs : var.public_route_table_ids[rt_key] if rt.vpc_key == each.key]
  )

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}-s3-endpoint" })
}

resource "aws_vpc_endpoint" "dynamodb" {
  for_each          = var.enable_dynamodb_endpoint ? var.vpc_configs : {}

  vpc_id            = var.vpc_ids[each.key]
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  # DynamoDB endpoints typically only need to be attached to private route tables
  route_table_ids = [
    for rt_key, rt in var.private_route_table_configs :
    var.private_route_table_ids[rt_key] if rt.vpc_key == each.key
  ]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}-dynamodb-endpoint" })
}

# ==============================================================
# Interface Endpoints Security Group
# ==============================================================

resource "aws_security_group" "vpc_endpoints" {
  for_each    = var.vpc_configs

  name_prefix = "${local.name_prefix}-${each.key}-vpce-sg-"
  vpc_id      = var.vpc_ids[each.key]
  description = "Allow HTTPS from VPC CIDR to interface endpoints"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [each.value.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}-vpce-sg" })
}

# ==============================================================
# Interface Endpoints (ENI-Based)
# ==============================================================

resource "aws_vpc_endpoint" "interface" {
  for_each            = local.vpc_ie_map

  vpc_id              = var.vpc_ids[each.value.vpc_key]
  service_name        = "com.amazonaws.${var.aws_region}.${each.value.service_name}"
  vpc_endpoint_type   = "Interface"

  # Filters private subnets to only deploy ENIs into subnets owned by this specific VPC
  subnet_ids = [
    for subnet_key, subnet in var.private_subnet_configs :
    var.private_subnet_ids[subnet_key] if subnet.vpc_key == each.value.vpc_key
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[each.value.vpc_key].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.value.vpc_key}-${each.value.service_name}-endpoint" })
}