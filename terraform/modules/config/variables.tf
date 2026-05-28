variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID used for AWS Config delivery"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN used for AWS Config notifications"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  type        = string
}