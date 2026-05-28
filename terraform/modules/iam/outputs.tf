output "admin_role_arn" {
  description = "ARN of the Security Administrator role"
  value       = aws_iam_role.security_admin.arn
}

output "audit_role_arn" {
  description = "ARN of the Security Auditor role"
  value       = aws_iam_role.security_auditor.arn
}

output "breakglass_role_arn" {
  description = "ARN of the emergency break-glass administrator role"
  value       = aws_iam_role.breakglass_admin.arn
  sensitive   = true
}

output "cloudtrail_role_arn" {
  description = "ARN of the IAM role used by CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "flow_logs_role_arn" {
  description = "ARN of the IAM role used by VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = aws_iam_role.config.arn
}

output "access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.account.arn
}