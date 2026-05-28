# ============================================================
# IAM Module — Roles, Password Policy, Access Analyzer
# ============================================================

# ============================================================
# IAM Account Password Policy
# ============================================================
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 90
  password_reuse_prevention      = 24
}

# ============================================================
# CloudTrail → CloudWatch Logs Role
# ============================================================
resource "aws_iam_role" "cloudtrail" {
  name        = "CloudTrailToCloudWatchLogsRole"
  description = "Allows CloudTrail to write to CloudWatch Logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Purpose = "CloudTrail to CloudWatch integration" }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "CloudTrailLogsPolicy"
  role = aws_iam_role.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "arn:aws:logs:*:${var.aws_account_id}:log-group:*"
    }]
  })
}

# ============================================================
# VPC Flow Logs Role
# ============================================================
resource "aws_iam_role" "flow_logs" {
  name        = "VPCFlowLogsRole"
  description = "Allows VPC Flow Logs to write to CloudWatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Purpose = "VPC Flow Logs delivery" }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "VPCFlowLogsPolicy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# ============================================================
# AWS Config Role
# ============================================================
resource "aws_iam_role" "config" {
  name        = "AWSConfigRole"
  description = "Role for AWS Config service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Purpose = "AWS Config service role" }
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_s3" {
  name = "ConfigS3DeliveryPolicy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetBucketAcl"]
        Resource = [
          var.log_bucket_arn,
          "${var.log_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# ============================================================
# Security Administrator Role
# ============================================================
resource "aws_iam_role" "security_admin" {
  name                 = var.admin_role_name
  description          = "Security Administrator — full security service access, MFA required"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.trusted_account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        Bool            = { "aws:MultiFactorAuthPresent" = "true" }
        NumericLessThan = { "aws:MultiFactorAuthAge" = "3600" }
      }
    }]
  })

  tags = {
    Purpose   = "Security administration"
    Sensitive = "true"
  }
}

resource "aws_iam_role_policy_attachment" "security_admin_readonly" {
  role       = aws_iam_role.security_admin.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "security_admin_custom" {
  name = "SecurityAdminCustomPolicy"
  role = aws_iam_role.security_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecurityServicesFullAccess"
        Effect = "Allow"
        Action = [
          "guardduty:*", "securityhub:*", "inspector2:*",
          "access-analyzer:*", "cloudtrail:*", "config:*",
          "cloudwatch:*", "logs:*",
          "iam:GetAccountPasswordPolicy", "iam:ListMFADevices",
          "iam:ListUsers", "iam:GetUser", "iam:ListAccessKeys",
          "iam:GenerateCredentialReport", "iam:GetCredentialReport"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDestructiveActions"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging", "cloudtrail:DeleteTrail",
          "guardduty:DeleteDetector", "securityhub:DisableSecurityHub",
          "config:DeleteConfigurationRecorder", "kms:ScheduleKeyDeletion",
          "s3:DeleteBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================
# Security Auditor Role (Read-Only)
# ============================================================
resource "aws_iam_role" "security_auditor" {
  name                 = var.audit_role_name
  description          = "Security Auditor — read-only access to security services"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.trusted_account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        Bool = { "aws:MultiFactorAuthPresent" = "true" }
      }
    }]
  })

  tags = { Purpose = "Security auditing" }
}

resource "aws_iam_role_policy_attachment" "auditor_readonly" {
  role       = aws_iam_role.security_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "auditor_securityaudit" {
  role       = aws_iam_role.security_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy" "auditor_custom" {
  name = "SecurityAuditorCustomPolicy"
  role = aws_iam_role.security_auditor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "SecurityServicesReadAccess"
      Effect = "Allow"
      Action = [
        "guardduty:Get*", "guardduty:List*",
        "securityhub:Get*", "securityhub:List*", "securityhub:Describe*",
        "inspector2:Get*", "inspector2:List*",
        "access-analyzer:Get*", "access-analyzer:List*",
        "cloudtrail:Get*", "cloudtrail:List*", "cloudtrail:Describe*",
        "config:Get*", "config:List*", "config:Describe*",
        "logs:Get*", "logs:Describe*", "logs:Filter*"
      ]
      Resource = "*"
    }]
  })
}

# ============================================================
# Break-Glass Emergency Admin Role
# ============================================================
resource "random_password" "breakglass_external_id" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "breakglass_external_id" {
  name        = "/baseline-security/breakglass/external-id"
  description = "External ID for break-glass role assumption — store securely"
  type        = "SecureString"
  value       = random_password.breakglass_external_id.result

  tags = { Purpose = "Break-glass role external ID" }
}

resource "aws_iam_role" "breakglass_admin" {
  name                 = var.breakglass_role_name
  description          = "EMERGENCY USE ONLY — full admin, 15-min MFA, external ID required"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.trusted_account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        Bool            = { "aws:MultiFactorAuthPresent" = "true" }
        NumericLessThan = { "aws:MultiFactorAuthAge" = "900" }
        StringEquals    = { "sts:ExternalId" = random_password.breakglass_external_id.result }
      }
    }]
  })

  tags = {
    Purpose   = "EMERGENCY break-glass access"
    Sensitive = "CRITICAL"
  }
}

resource "aws_iam_role_policy_attachment" "breakglass_admin" {
  role       = aws_iam_role.breakglass_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ============================================================
# IAM Access Analyzer
# ============================================================
resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "baseline-account-analyzer"
  type          = "ACCOUNT"

  tags = { Purpose = "IAM policy analysis" }
}
