# ==============================================================
# AWS Secrets Manager
# ==============================================================

# 1. Generate a unique random password for each secret in the map
resource "random_password" "passwords" {
  for_each         = var.secrets

  length           = 16
  special          = true
  override_special = "_%@"
}

# 2. Create the Secret container
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

# 3. Construct and store the secure JSON payload
resource "aws_secretsmanager_secret_version" "versions" {
  for_each      = var.secrets

  secret_id     = aws_secretsmanager_secret.secrets[each.key].id

  # Dynamically construct the JSON payload using the username from variables 
  # and the randomly generated password from the resource above
  secret_string = jsonencode({
    username = each.value.username
    password = random_password.passwords[each.key].result
  })
}
