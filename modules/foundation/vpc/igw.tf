# ==============================================================
# Internet Gateway Module
# Creates one IGW per VPC automatically
# ==============================================================

resource "aws_internet_gateway" "this" {
  for_each = aws_vpc.this

  vpc_id = each.value.id

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}-igw"
    VPCName = each.key
    VPCID   = each.value.id
  })
}
