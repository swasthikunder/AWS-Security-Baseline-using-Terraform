# ============================================================
# KMS Module — Customer Managed Keys
# ============================================================

# ============================================================
# KMS Key for Security Logs
# Used By:
# - CloudTrail
# - CloudWatch Logs
# - AWS Config
# ============================================================

resource "aws_kms_key" "logs" {
  description             = "KMS CMK for baseline security log encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },

      {
        Sid    = "AllowCloudTrailEncryption"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"

        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"
          }
        }
      },

      {
        Sid    = "AllowCloudWatchLogsEncryption"
        Effect = "Allow"

        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }

        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"

        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:*"
          }
        }
      },

      {
        Sid    = "AllowConfigEncryption"
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]

        Resource = "*"
      },

      {
        Sid    = "DenyKeyDeletion"
        Effect = "Deny"

        Principal = {
          AWS = "*"
        }

        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:DeleteImportedKeyMaterial"
        ]

        Resource = "*"

        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.aws_account_id}:root"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-baseline-security-logs-key"
    Environment = var.environment
    Purpose     = "Log encryption for baseline security"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.environment}-baseline-security-logs"
  target_key_id = aws_kms_key.logs.key_id
}

# ============================================================
# Separate KMS Key for S3 Data Encryption
# Defense-in-depth design
# ============================================================

resource "aws_kms_key" "s3_data" {
  description             = "KMS CMK for S3 data encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },

      {
        Sid    = "AllowS3ServiceEncryption"
        Effect = "Allow"

        Principal = {
          Service = "s3.amazonaws.com"
        }

        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]

        Resource = "*"
      },

      {
        Sid    = "DenyKeyDeletion"
        Effect = "Deny"

        Principal = {
          AWS = "*"
        }

        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:DeleteImportedKeyMaterial"
        ]

        Resource = "*"

        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.aws_account_id}:root"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-baseline-security-s3-key"
    Environment = var.environment
    Purpose     = "S3 data encryption"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "s3_data" {
  name          = "alias/${var.environment}-baseline-security-s3"
  target_key_id = aws_kms_key.s3_data.key_id
}