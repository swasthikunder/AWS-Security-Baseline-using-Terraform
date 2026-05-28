variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "finding_frequency" {
  description = "Frequency for publishing GuardDuty findings"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN used for GuardDuty alerts"
  type        = string
}