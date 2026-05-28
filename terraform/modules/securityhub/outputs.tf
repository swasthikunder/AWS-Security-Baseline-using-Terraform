output "securityhub_enabled" {
  description = "Indicates whether AWS Security Hub is enabled"
  value       = true
}

output "securityhub_account_id" {
  description = "Security Hub account identifier"
  value       = aws_securityhub_account.baseline.id
}

output "fsbp_subscription_arn" {
  description = "ARN of the AWS Foundational Security Best Practices subscription"
  value       = aws_securityhub_standards_subscription.fsbp.id
}

output "cis_subscription_arn" {
  description = "ARN of the CIS AWS Foundations Benchmark subscription"
  value       = aws_securityhub_standards_subscription.cis.id
}