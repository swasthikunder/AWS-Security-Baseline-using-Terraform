variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID for CloudTrail log storage"
  type        = string
}

variable "s3_log_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for CloudTrail encryption"
  type        = string
}

variable "cloudtrail_role_arn" {
  description = "IAM role ARN used by CloudTrail for CloudWatch logging"
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs"
  type        = number
}