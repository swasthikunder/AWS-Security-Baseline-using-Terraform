variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for S3 bucket encryption"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used for naming and bucket policies"
  type        = string
}

variable "aws_region" {
  description = "AWS region used for regional resources"
  type        = string
  default     = "us-east-1"
}