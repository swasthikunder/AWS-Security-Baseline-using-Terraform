# ============================================================
# CloudWatch Module — SNS, Metric Filters, Alarms, Dashboard
# Safe & Terraform-Valid Version
# ============================================================

resource "aws_sns_topic" "security_alerts" {
  name              = "baseline-security-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Environment = var.environment
    Purpose     = "Security alert notifications"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/baseline-flow-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Purpose     = "VPC Flow Logs"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Helper locals
# ============================================================

locals {
  alarm_actions = [aws_sns_topic.security_alerts.arn]
}

# ============================================================
# Root Login Detection
# ============================================================

resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "RootAccountLogin"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "RootAccountLoginCount"
    namespace = "BaselineSecurity/IAM"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "baseline-root-account-login"
  alarm_description   = "CRITICAL: Root account login detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountLoginCount"
  namespace           = "BaselineSecurity/IAM"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = {
    Severity    = "CRITICAL"
    Environment = var.environment
  }
}

# ============================================================
# Unauthorized API Calls
# ============================================================

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
  name           = "UnauthorizedAPICalls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedAccess\") || ($.errorCode = \"AccessDenied\") }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "UnauthorizedAPICallCount"
    namespace = "BaselineSecurity/IAM"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "baseline-unauthorized-api-calls"
  alarm_description   = "Multiple unauthorized API calls detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICallCount"
  namespace           = "BaselineSecurity/IAM"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_actions       = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = {
    Severity    = "HIGH"
    Environment = var.environment
  }
}

# ============================================================
# Console Login Without MFA
# ============================================================

resource "aws_cloudwatch_log_metric_filter" "console_no_mfa" {
  name           = "ConsoleLoginWithoutMFA"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "ConsoleLoginNoMFACount"
    namespace = "BaselineSecurity/IAM"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_no_mfa" {
  alarm_name          = "baseline-console-login-no-mfa"
  alarm_description   = "Console login detected without MFA"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginNoMFACount"
  namespace           = "BaselineSecurity/IAM"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = {
    Severity    = "HIGH"
    Environment = var.environment
  }
}

# ============================================================
# CloudTrail Changes
# ============================================================

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_changes" {
  name           = "CloudTrailChanges"
  pattern        = "{ ($.eventSource = \"cloudtrail.amazonaws.com\") && (($.eventName != \"DescribeTrails\") && ($.eventName != \"GetTrailStatus\") && ($.eventName != \"LookupEvents\")) }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "CloudTrailChangeCount"
    namespace = "BaselineSecurity/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_changes" {
  alarm_name          = "baseline-cloudtrail-changes"
  alarm_description   = "CRITICAL: CloudTrail configuration changed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CloudTrailChangeCount"
  namespace           = "BaselineSecurity/CloudTrail"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = {
    Severity    = "CRITICAL"
    Environment = var.environment
  }
}

# ============================================================
# KMS Key Changes
# ============================================================

resource "aws_cloudwatch_log_metric_filter" "kms_cmk_changes" {
  name           = "KMSCMKDeletionOrDisable"
  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && (($.eventName = \"DisableKey\") || ($.eventName = \"ScheduleKeyDeletion\")) }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "KMSCMKChangeCount"
    namespace = "BaselineSecurity/KMS"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_cmk_changes" {
  alarm_name          = "baseline-kms-cmk-deletion-disable"
  alarm_description   = "CRITICAL: KMS key deletion or disablement detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KMSCMKChangeCount"
  namespace           = "BaselineSecurity/KMS"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = {
    Severity    = "CRITICAL"
    Environment = var.environment
  }
}

# ============================================================
# Security Dashboard
# ============================================================

resource "aws_cloudwatch_dashboard" "security" {
  dashboard_name = "BaselineSecurityDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = "# AWS Baseline Security Dashboard\nReal-time security monitoring."
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 2
        width  = 24
        height = 6

        properties = {
          title = "Security Alarm Status"

          alarms = [
            aws_cloudwatch_metric_alarm.root_login.arn,
            aws_cloudwatch_metric_alarm.unauthorized_api.arn,
            aws_cloudwatch_metric_alarm.console_no_mfa.arn,
            aws_cloudwatch_metric_alarm.cloudtrail_changes.arn,
            aws_cloudwatch_metric_alarm.kms_cmk_changes.arn
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6

        properties = {
          title   = "Root Account Logins"
          view    = "timeSeries"
          metrics = [["BaselineSecurity/IAM", "RootAccountLoginCount"]]
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6

        properties = {
          title   = "Unauthorized API Calls"
          view    = "timeSeries"
          metrics = [["BaselineSecurity/IAM", "UnauthorizedAPICallCount"]]
          period  = 300
          stat    = "Sum"
        }
      }
    ]
  })
}