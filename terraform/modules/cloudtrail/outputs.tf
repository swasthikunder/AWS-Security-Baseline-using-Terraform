output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.baseline.arn
}

output "trail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.baseline.name
}

output "log_group_name" {
  description = "CloudWatch Log Group name for CloudTrail logs"
  value       = aws_cloudwatch_log_group.trail.name
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN for CloudTrail logs"
  value       = aws_cloudwatch_log_group.trail.arn
}