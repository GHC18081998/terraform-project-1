# ==============================================================
# VPC Endpoint Outputs
# ==============================================================

output "s3_endpoint_ids" {
  description = "Map of VPC name to S3 Gateway Endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.s3 : k => v.id }
}

output "dynamodb_endpoint_ids" {
  description = "Map of VPC name to DynamoDB Gateway Endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.dynamodb : k => v.id }
}

output "interface_endpoint_ids" {
  description = "Map of VPC-Service combinations to Interface Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "vpc_endpoints_security_group_ids" {
  description = "Map of VPC name to VPC Endpoints Security Group ID"
  value       = { for k, v in aws_security_group.vpc_endpoints : k => v.id }
}