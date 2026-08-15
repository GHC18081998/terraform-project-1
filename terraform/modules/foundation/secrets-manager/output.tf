# ==============================================================
# Secrets Manager Outputs
# ==============================================================

output "secret_arns" {
  description = "Map of secret keys to their corresponding ARNs"
  value       = { for k, v in aws_secretsmanager_secret.secrets : k => v.arn }
}

output "secret_names" {
  description = "Map of secret keys to their corresponding names"
  value       = { for k, v in aws_secretsmanager_secret.secrets : k => v.name }
}