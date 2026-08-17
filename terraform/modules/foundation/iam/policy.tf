# ==============================================================
# IAM Policy Configuration
# ==============================================================

resource "aws_iam_policy" "policies" {
  for_each    = var.policies
  name        = "${local.name_prefix}-${each.key}-policy"
  description = each.value.description
  policy      = each.value.policy_json
}

# ==============================================================
# IAM Role Policy Attachments
# ==============================================================

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each   = var.role_policy_attachments

  # References the 'roles' resource we renamed in the previous step
  role       = aws_iam_role.roles[each.value.role_key].name

  # References the 'policies' resource we just renamed above
  policy_arn = startswith(each.value.policy_key, "arn:") ? each.value.policy_key : aws_iam_policy.policies[each.value.policy_key].arn
}