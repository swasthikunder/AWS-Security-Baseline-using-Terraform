# ============================================================
# Amazon Inspector Module
# ============================================================

resource "aws_inspector2_enabler" "baseline" {
  account_ids = [
    var.aws_account_id
  ]

  # ============================================================
  # Reduced Resource Types for Safer Testing
  # ============================================================

  resource_types = [
    "EC2"
  ]
}

# ============================================================
# EventBridge Rule for High Severity Findings
# ============================================================

resource "aws_cloudwatch_event_rule" "inspector_findings" {
  name        = "baseline-inspector-findings"
  description = "Capture Inspector HIGH and CRITICAL findings"

  event_pattern = jsonencode({
    source = [
      "aws.inspector2"
    ]

    detail-type = [
      "Inspector2 Finding"
    ]

    detail = {
      severity = [
        "HIGH",
        "CRITICAL"
      ]
    }
  })

  tags = {
    Environment = var.environment
    Purpose     = "Inspector alert routing"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_event_target" "inspector_to_sns" {
  rule      = aws_cloudwatch_event_rule.inspector_findings.name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      title       = "$.detail.title"
      description = "$.detail.description"
      resource    = "$.detail.resources[0].id"
    }

    input_template = "\"Inspector ALERT | Severity: <severity> | Title: <title> | Resource: <resource> | Details: <description>\""
  }
}