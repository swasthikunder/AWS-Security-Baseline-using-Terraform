variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "monthly_budget_limit" {
  description = "Monthly AWS budget limit in USD"
  type        = string
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold percentage"
  type        = number
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for budget notifications"
  type        = string
}