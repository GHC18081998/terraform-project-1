# ==============================================================
# Secrets Manager Rotation
# ==============================================================

resource "aws_secretsmanager_secret_rotation" "rotation" {
  # Only configures rotation if a Lambda ARN is explicitly provided
  for_each            = { for k, v in var.secrets : k => v if v.rotation_lambda_arn != null }

  # Updated from .this to .secrets
  secret_id           = aws_secretsmanager_secret.secrets[each.key].id
  rotation_lambda_arn = each.value.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = each.value.rotation_days
  }
}