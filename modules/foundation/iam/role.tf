# ==============================================================
# IAM Role Configuration
# ==============================================================

resource "aws_iam_role" "roles" {
  for_each           = var.roles
  name               = "${local.name_prefix}-${each.key}-role"

  # References the data block
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-role"
  })
}