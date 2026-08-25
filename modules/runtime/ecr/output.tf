output "repository_urls" {
  description = "Map of repository names to their ECR URLs"
  value       = { for k, v in aws_ecr_repository.registry : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository names to their full ARNs"
  value       = { for k, v in aws_ecr_repository.registry : k => v.arn }
}

output "repository_names" {
  description = "Map of key identifiers to deployed AWS ECR names"
  value       = { for k, v in aws_ecr_repository.registry : k => v.name }
}