variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "admin_role_name" {
  description = "Name of the Security Administrator IAM role"
  type        = string
}

variable "audit_role_name" {
  description = "Name of the Security Auditor IAM role"
  type        = string
}

variable "breakglass_role_name" {
  description = "Name of the emergency break-glass administrator role"
  type        = string
}

variable "trusted_account_id" {
  description = "AWS account ID allowed to assume cross-account roles"
  type        = string
}

variable "aws_account_id" {
  description = "Current AWS account ID"
  type        = string
}

variable "log_bucket_arn" {
  description = "ARN of the centralized logging S3 bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for encryption operations"
  type        = string
}