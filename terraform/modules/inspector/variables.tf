variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used for Inspector enablement"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN used for Inspector security alerts"
  type        = string
}