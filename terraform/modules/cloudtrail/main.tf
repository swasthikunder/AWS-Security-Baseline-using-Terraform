# ============================================================
# CloudTrail Module
# Safe & Cost-Aware Version
# ============================================================

resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws/cloudtrail/baseline-security-trail"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Purpose     = "CloudTrail log delivery"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudtrail" "baseline" {
  name           = var.cloudtrail_name
  s3_bucket_name = var.s3_bucket_id
  s3_key_prefix  = var.s3_log_prefix

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  kms_key_id = var.kms_key_arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn  = var.cloudtrail_role_arn

  # ============================================================
  # SAFE MANAGEMENT EVENTS ONLY
  # Avoids expensive S3/Lambda data event charges
  # ============================================================

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  # ============================================================
  # CloudTrail Insights
  # ============================================================

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  insight_selector {
    insight_type = "ApiErrorRateInsight"
  }

  tags = {
    Name        = var.cloudtrail_name
    Environment = var.environment
    Purpose     = "Centralized multi-region audit logging"
    ManagedBy   = "Terraform"
  }
}
