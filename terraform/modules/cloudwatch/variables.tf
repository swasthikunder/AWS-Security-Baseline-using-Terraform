variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "alert_email" {
  description = "Email address used for CloudWatch SNS security alerts"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name used for metric filters"
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch log groups"
  type        = number
}