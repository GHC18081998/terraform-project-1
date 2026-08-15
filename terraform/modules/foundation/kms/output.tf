# ==============================================================
# KMS Outputs
# ==============================================================

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "The alias name of the key"
  value       = aws_kms_alias.this.name
}
