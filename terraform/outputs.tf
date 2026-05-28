output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

output "kms_log_key_arn" {
  description = "KMS key ARN for log encryption"
  value       = module.kms.log_key_arn
}

output "log_archive_bucket_id" {
  description = "S3 bucket name for log archiving"
  value       = module.s3_log_archive.bucket_id
}

output "log_archive_bucket_arn" {
  description = "S3 bucket ARN for log archiving"
  value       = module.s3_log_archive.bucket_arn
}

output "admin_role_arn" {
  description = "ARN of the SecurityAdministrator role"
  value       = module.iam.admin_role_arn
}

output "audit_role_arn" {
  description = "ARN of the SecurityAuditor role"
  value       = module.iam.audit_role_arn
}

output "breakglass_role_arn" {
  description = "ARN of the BreakGlassAdmin role"
  value       = module.iam.breakglass_role_arn
  sensitive   = true
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_log_group" {
  description = "CloudWatch Log Group for CloudTrail"
  value       = module.cloudtrail.log_group_name
}

output "vpc_id" {
  description = "ID of the baseline VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# output "guardduty_detector_id" {
#   description = "GuardDuty detector ID"
#   value       = module.guardduty.detector_id
# }

output "alert_sns_topic_arn" {
  description = "SNS topic ARN for security alerts"
  value       = module.cloudwatch.alert_sns_arn
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch security dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${module.cloudwatch.dashboard_name}"
}
