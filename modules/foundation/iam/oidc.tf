# ==============================================================
# OIDC Identity Providers (e.g., GitHub Actions, GitLab CI)
# ==============================================================

resource "aws_iam_openid_connect_provider" "providers" {
  for_each        = var.oidc_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-oidc"
  })
}

# ==============================================================
# Roles federated via OIDC (assumed by CI/CD, not by IAM users)
# ==============================================================

resource "aws_iam_role" "oidc_roles" {
  for_each           = var.oidc_roles
  name               = "${local.name_prefix}-${each.key}-oidc-role"

  # References the OIDC data block we fixed in data.tf
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role[each.key].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-oidc-role"
  })
}

# ==============================================================
# OIDC Role Policy Attachments
# ==============================================================

resource "aws_iam_role_policy_attachment" "oidc_attachments" {
  for_each   = var.oidc_role_policy_attachments

  role       = aws_iam_role.oidc_roles[each.value.oidc_role_key].name

  # Updated from aws_iam_policy.this to aws_iam_policy.policies
  policy_arn = startswith(each.value.policy_key, "arn:") ? each.value.policy_key : aws_iam_policy.policies[each.value.policy_key].arn
}