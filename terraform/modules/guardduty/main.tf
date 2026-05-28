# ============================================================
# GuardDuty Module
# ============================================================

resource "aws_guardduty_detector" "baseline" {
  enable = true

  finding_publishing_frequency = var.finding_frequency

  tags = {
    Name        = "baseline-guardduty"
    Environment = var.environment
    Purpose     = "Continuous threat detection"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# EventBridge Rule for High Severity Findings
# ============================================================

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "baseline-guardduty-findings"
  description = "Capture GuardDuty HIGH severity findings"

  event_pattern = jsonencode({
    source = [
      "aws.guardduty"
    ]

    detail-type = [
      "GuardDuty Finding"
    ]

    detail = {
      severity = [
        {
          numeric = [
            ">=",
            7
          ]
        }
      ]
    }
  })

  tags = {
    Environment = var.environment
    Purpose     = "GuardDuty alert routing"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_event_target" "guardduty_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      type        = "$.detail.type"
      description = "$.detail.description"
      region      = "$.region"
      account     = "$.account"
    }

    input_template = "\"GuardDuty ALERT | Severity: <severity> | Type: <type> | Account: <account> | Region: <region> | Description: <description>\""
  }
}