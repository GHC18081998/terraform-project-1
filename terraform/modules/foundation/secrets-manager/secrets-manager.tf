# ==============================================================
# AWS Secrets Manager
# ==============================================================

resource "aws_secretsmanager_secret" "secrets" {
  for_each                = var.secrets

  name                    = "${local.name_prefix}-${each.key}"
  description             = each.value.description
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}

resource "aws_secretsmanager_secret_version" "versions" {
  for_each      = var.secrets

  # Updated from .this to .secrets to match the new resource name
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id

  # A best practice is to pass a JSON-encoded map here for structured secrets
  secret_string = each.value.secret_string
}