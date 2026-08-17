# ==============================================================================
# RDS Subnet Group
# ==============================================================================

resource "aws_db_subnet_group" "rds" {
  name        = local.subnet_group_name
  description = "Subnet group for RDS instance - ${local.db_identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.common_tags, {
    Name    = local.subnet_group_name
    Purpose = "RDS Subnet Group"
  })
  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Data Source - Subnet Information
# ==============================================================================

data "aws_subnet" "rds_subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}