output "alert_sns_arn" {
  description = "ARN of the SNS topic used for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch security dashboard"
  value       = aws_cloudwatch_dashboard.security.dashboard_name
}

output "vpc_flow_log_group_name" {
  description = "Name of the VPC Flow Logs CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}