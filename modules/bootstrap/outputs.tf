output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].name : null
}

output "ec2_describe_policy_arn" {
  description = "ARN of the EC2 describe policy"
  value       = var.enabled ? aws_iam_policy.ec2_describe[0].arn : null
}

output "vpc_core_policy_arn" {
  description = "ARN of the VPC core management policy"
  value       = var.enabled ? aws_iam_policy.vpc_core[0].arn : null
}

output "vpc_networking_policy_arn" {
  description = "ARN of the VPC networking policy"
  value       = var.enabled ? aws_iam_policy.vpc_networking[0].arn : null
}

output "aws_services_policy_arn" {
  description = "ARN of the AWS services policy"
  value       = var.enabled ? aws_iam_policy.aws_services[0].arn : null
}

output "iam_kms_policy_arn" {
  description = "ARN of the IAM and KMS management policy"
  value       = var.enabled ? aws_iam_policy.iam_kms[0].arn : null
}

output "policy_arns" {
  description = "List of all policy ARNs attached to the GitHub Actions role"
  value = var.enabled ? [
    aws_iam_policy.ec2_describe[0].arn,
    aws_iam_policy.vpc_core[0].arn,
    aws_iam_policy.vpc_networking[0].arn,
    aws_iam_policy.aws_services[0].arn,
    aws_iam_policy.iam_kms[0].arn
  ] : []
}