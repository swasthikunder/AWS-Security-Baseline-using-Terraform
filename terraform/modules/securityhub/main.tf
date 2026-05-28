# ============================================================
# Security Hub Module
# ============================================================

resource "aws_securityhub_account" "baseline" {}

# ============================================================
# AWS Foundational Security Best Practices
# ============================================================

resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [
    aws_securityhub_account.baseline
  ]
}

# ============================================================
# CIS AWS Foundations Benchmark
# ============================================================

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"

  depends_on = [
    aws_securityhub_account.baseline
  ]
}

# ============================================================
# Access Analyzer Integration
# ============================================================

resource "aws_securityhub_product_subscription" "access_analyzer" {
  product_arn = "arn:aws:securityhub:${var.aws_region}::product/aws/access-analyzer"

  depends_on = [
    aws_securityhub_account.baseline
  ]
}