# ============================================================
# Global Variables
# ============================================================

variable "aws_region" {
  description = "Primary AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"

  type    = string
  default = "sandbox"

  validation {
    condition = contains(
      [
        "production",
        "staging",
        "sandbox",
        "development"
      ],
      var.environment
    )

    error_message = "Environment must be one of: production, staging, sandbox, development."
  }
}

variable "owner_email" {
  description = "Email of the account owner or team used for tagging"

  type = string
}

variable "alert_email" {
  description = "Email address used for security and budget alerts"

  type = string
}

# ============================================================
# IAM Configuration
# ============================================================

variable "admin_role_name" {
  description = "Name for the Security Administrator IAM role"

  type    = string
  default = "SecurityAdministrator"
}

variable "audit_role_name" {
  description = "Name for the Security Auditor IAM role"

  type    = string
  default = "SecurityAuditor"
}

variable "breakglass_role_name" {
  description = "Name for the break-glass emergency IAM role"

  type    = string
  default = "BreakGlassAdmin"
}

variable "trusted_account_id" {
  description = "AWS account ID allowed to assume roles. Leave empty to use current account."

  type    = string
  default = ""
}

# ============================================================
# VPC Configuration
# ============================================================

variable "vpc_cidr" {
  description = "CIDR block for the baseline VPC"

  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"

  type = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"

  type = list(string)

  default = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}

variable "availability_zones" {
  description = "Availability zones used for subnet deployment"

  type = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

# ============================================================
# NAT Gateway
# WARNING:
# NAT Gateways can incur significant AWS charges.
# Keep disabled for ₹0-safe deployments.
# ============================================================

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways"

  type    = bool
  default = false
}

# ============================================================
# Budget Configuration
# ============================================================

variable "monthly_budget_limit" {
  description = "Monthly AWS budget limit in USD"

  type    = string
  default = "5"
}

variable "budget_alert_threshold" {
  description = "Percentage threshold for budget alerts"

  type    = number
  default = 80
}

# ============================================================
# CloudTrail Configuration
# ============================================================

variable "cloudtrail_name" {
  description = "Name for the CloudTrail trail"

  type    = string
  default = "BaselineSecurityTrail"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"

  type    = number
  default = 30
}

variable "s3_log_prefix" {
  description = "S3 prefix used for CloudTrail log storage"

  type    = string
  default = "cloudtrail-logs"
}

# ============================================================
# Optional Advanced Security Modules
# Currently disabled in root main.tf
# for ₹0-safe deployment
# ============================================================

variable "guardduty_finding_frequency" {
  description = "Frequency for GuardDuty finding publication"

  type    = string
  default = "SIX_HOURS"

  validation {
    condition = contains(
      [
        "FIFTEEN_MINUTES",
        "ONE_HOUR",
        "SIX_HOURS"
      ],
      var.guardduty_finding_frequency
    )

    error_message = "Finding frequency must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}