variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used for KMS key policies"
  type        = string
}

variable "aws_region" {
  description = "AWS region used for regional KMS service integrations"
  type        = string
}