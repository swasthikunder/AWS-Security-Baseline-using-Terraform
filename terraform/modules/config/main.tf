# ============================================================
# AWS Config Module
# Safe & Terraform-Valid Version
# ============================================================

resource "aws_iam_role" "config" {
  name = "AWSConfigRoleBaseline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "AWS Config recorder role"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "baseline" {
  name     = "baseline-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "baseline" {
  name           = "baseline-config-delivery"
  s3_bucket_name = var.s3_bucket_id
  s3_key_prefix  = "config-logs"
  sns_topic_arn  = var.sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [
    aws_config_configuration_recorder.baseline
  ]
}

resource "aws_config_configuration_recorder_status" "baseline" {
  name       = aws_config_configuration_recorder.baseline.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.baseline
  ]
}

# ============================================================
# Core Managed Rules Only
# Reduced for Simplicity & Cost Awareness
# ============================================================

resource "aws_config_config_rule" "cloudtrail_enabled" {
  name = "cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.baseline
  ]
}

resource "aws_config_config_rule" "root_mfa_enabled" {
  name = "root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.baseline
  ]
}

resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters = "true"
    RequireLowercaseCharacters = "true"
    RequireSymbols             = "true"
    RequireNumbers             = "true"
    MinimumPasswordLength      = "14"
    PasswordReusePrevention    = "24"
    MaxPasswordAge             = "90"
  })

  depends_on = [
    aws_config_configuration_recorder_status.baseline
  ]
}

resource "aws_config_config_rule" "s3_public_access_blocked" {
  name = "s3-account-level-public-access-blocks"

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS_PERIODIC"
  }

  input_parameters = jsonencode({
    BlockPublicAcls       = "true"
    BlockPublicPolicy     = "true"
    IgnorePublicAcls      = "true"
    RestrictPublicBuckets = "true"
  })

  depends_on = [
    aws_config_configuration_recorder_status.baseline
  ]
}

resource "aws_config_config_rule" "kms_rotation" {
  name = "cmk-backing-key-rotation-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CMK_BACKING_KEY_ROTATION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.baseline
  ]
}