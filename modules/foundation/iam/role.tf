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

# ==============================================================
# IAM Instance Profiles Configuration
# ==============================================================

resource "aws_iam_instance_profile" "profiles" {
  for_each = var.roles
  name     = "${local.name_prefix}-${each.key}-profile"
  role     = aws_iam_role.roles[each.key].name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-profile"
  })
}
