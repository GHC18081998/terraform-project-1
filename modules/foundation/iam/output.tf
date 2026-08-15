# ==============================================================
# Standard IAM Outputs
# ==============================================================

output "role_arns" {
  description = "Map of standard IAM role keys to their corresponding ARNs"
  value = {
    # Updated from aws_iam_role.roles
    for k, v in aws_iam_role.roles : k => v.arn
  }
}

output "role_names" {
  description = "Map of standard IAM role keys to their corresponding names"
  value = {
    # Updated from aws_iam_role.roles
    for k, v in aws_iam_role.roles : k => v.name
  }
}

output "policy_arns" {
  description = "Map of standard IAM policy keys to their corresponding ARNs"
  value = {
    # Updated from aws_iam_policy.policies
    for k, v in aws_iam_policy.policies : k => v.arn
  }
}

# ==============================================================
# OIDC Federation Outputs
# ==============================================================

output "oidc_provider_arns" {
  description = "Map of OIDC provider keys to their corresponding ARNs"
  value = {
    # Updated from aws_iam_openid_connect_provider.providers
    for k, v in aws_iam_openid_connect_provider.providers : k => v.arn
  }
}

output "oidc_role_arns" {
  description = "Map of OIDC role keys to their corresponding ARNs"
  value = {
    # Updated from aws_iam_role.oidc_roles
    for k, v in aws_iam_role.oidc_roles : k => v.arn
  }
}