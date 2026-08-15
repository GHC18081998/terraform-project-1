# ==============================================================================
# RDS Security Group
# ==============================================================================

resource "aws_security_group" "rds" {
  name        = local.security_group_name
  description = "Security group for RDS instance - ${local.db_identifier}"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name    = local.security_group_name
    Purpose = "RDS Access Control"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Security Group Rules - Ingress from CIDR Blocks
# ==============================================================================

resource "aws_security_group_rule" "rds_ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow DB access from specified CIDR blocks"
}

# ==============================================================================
# Security Group Rules - Ingress from Security Groups
# ==============================================================================

resource "aws_security_group_rule" "rds_ingress_sg" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.rds.id
  description              = "Allow DB access from security group ${var.allowed_security_group_ids[count.index]}"
}

# ==============================================================================
# Security Group Rules - Egress
# ==============================================================================

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
}