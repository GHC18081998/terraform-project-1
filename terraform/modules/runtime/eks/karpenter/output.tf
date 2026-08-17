# ==============================================================================
# Karpenter Controller & Node IAM Outputs
# ==============================================================================
output "karpenter_iam_role_arn" {
  description = "ARN of the IAM role for Karpenter controller"
  value       = try(aws_iam_role.node[0].arn, "")
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by Karpenter-provisioned EC2 nodes"
  value       = try(aws_iam_role.node[0].arn, "")
}

# ==============================================================================
# Karpenter Interruption Queue Outputs
# ==============================================================================
output "interruption_queue_arn" {
  description = "ARN of the SQS queue for Karpenter interruption handling"
  value       = var.enable_spot_termination_handling ? aws_sqs_queue.interruption[0].arn : null
}

output "interruption_queue_name" {
  description = "Name of the SQS queue for Karpenter interruption handling"
  value       = var.enable_spot_termination_handling ? aws_sqs_queue.interruption[0].name : null
}

# ==============================================================================
# Karpenter Helm Release Outputs
# ==============================================================================
output "helm_release_status" {
  description = "Status of the Karpenter Helm release"
  value       = var.enable_karpenter ? helm_release.karpenter[0].status : null
}