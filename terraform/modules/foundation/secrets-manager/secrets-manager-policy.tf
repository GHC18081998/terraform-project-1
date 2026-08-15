# ==============================================================
# Secrets Manager Resource Policies
# ==============================================================

resource "aws_secretsmanager_secret_policy" "policies" {
  # Only creates a policy if the user provided one in the variable map
  for_each   = { for k, v in var.secrets : k => v if v.resource_policy_json != null }

  # Updated from .this to .secrets
  secret_arn = aws_secretsmanager_secret.secrets[each.key].arn
  policy     = each.value.resource_policy_json
}
