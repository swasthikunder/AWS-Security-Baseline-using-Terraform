# ============================================================
# AWS Account Baseline Security — Root Module
# ============================================================

# ============================================================
# AWS Account & Region Information
# ============================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# ============================================================
# KMS Module
# Customer Managed Encryption Keys
# ============================================================

module "kms" {
  source = "./modules/kms"

  environment    = var.environment
  aws_account_id = local.account_id
  aws_region     = local.region
}

# ============================================================
# S3 Centralized Log Archive
# ============================================================

module "s3_log_archive" {
  source = "./modules/s3"

  environment    = var.environment
  kms_key_arn    = module.kms.log_key_arn
  aws_account_id = local.account_id
  aws_region     = local.region

  depends_on = [
    module.kms
  ]
}

# ============================================================
# IAM Security Baseline
# - Security Admin Role
# - Security Auditor Role
# - Break-glass Access
# - Password Policy
# - Access Analyzer
# ============================================================

module "iam" {
  source = "./modules/iam"

  environment          = var.environment
  admin_role_name      = var.admin_role_name
  audit_role_name      = var.audit_role_name
  breakglass_role_name = var.breakglass_role_name

  trusted_account_id = (
    var.trusted_account_id != ""
    ? var.trusted_account_id
    : local.account_id
  )

  aws_account_id = local.account_id
  log_bucket_arn = module.s3_log_archive.bucket_arn
  kms_key_arn    = module.kms.log_key_arn

  depends_on = [
    module.s3_log_archive
  ]
}

# ============================================================
# CloudTrail Audit Logging
# ============================================================

module "cloudtrail" {
  source = "./modules/cloudtrail"

  environment         = var.environment
  cloudtrail_name     = var.cloudtrail_name
  s3_bucket_id        = module.s3_log_archive.bucket_id
  s3_log_prefix       = var.s3_log_prefix
  kms_key_arn         = module.kms.log_key_arn
  cloudtrail_role_arn = module.iam.cloudtrail_role_arn
  log_retention_days  = var.log_retention_days

  depends_on = [
    module.iam,
    module.s3_log_archive
  ]
}

# ============================================================
# CloudWatch Monitoring & SNS Alerts
# ============================================================

module "cloudwatch" {
  source = "./modules/cloudwatch"

  environment        = var.environment
  alert_email        = var.alert_email
  log_group_name     = module.cloudtrail.log_group_name
  log_retention_days = var.log_retention_days

  depends_on = [
    module.cloudtrail
  ]
}

# ============================================================
# VPC Security Baseline
# NAT Gateway intentionally disabled for ₹0-safe deployment
# ============================================================

module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  # ============================================================
  # KEEP FALSE — NAT Gateway can incur significant charges
  # ============================================================

  enable_nat_gateway = false

  flow_log_role_arn  = module.iam.flow_logs_role_arn
  log_retention_days = var.log_retention_days

  depends_on = [
    module.iam
  ]
}

# ============================================================
# AWS Budgets
# Cost Monitoring & Alerts
# ============================================================

module "budgets" {
  source = "./modules/budgets"

  environment            = var.environment
  monthly_budget_limit   = var.monthly_budget_limit
  budget_alert_threshold = var.budget_alert_threshold
  alert_email            = var.alert_email
  sns_topic_arn          = module.cloudwatch.alert_sns_arn

  depends_on = [
    module.cloudwatch
  ]
}

# ============================================================
# OPTIONAL ADVANCED SECURITY MODULES
# COMMENTED OUT FOR ₹0-SAFE DEPLOYMENT
# ============================================================

# ============================================================
# AWS Config
# Can generate compliance/configuration item charges
# ============================================================

# module "config" {
#   source = "./modules/config"
#
#   environment    = var.environment
#   s3_bucket_id   = module.s3_log_archive.bucket_id
#   sns_topic_arn  = module.cloudwatch.alert_sns_arn
#   aws_account_id = local.account_id
#   kms_key_arn    = module.kms.log_key_arn
#
#   depends_on = [
#     module.s3_log_archive,
#     module.cloudwatch
#   ]
# }

# ============================================================
# GuardDuty
# Paid threat detection service
# ============================================================

# module "guardduty" {
#   source = "./modules/guardduty"
#
#   environment       = var.environment
#   finding_frequency = var.guardduty_finding_frequency
#   sns_topic_arn     = module.cloudwatch.alert_sns_arn
#
#   depends_on = [
#     module.cloudwatch
#   ]
# }

# ============================================================
# Security Hub
# Paid security posture management service
# ============================================================

# module "securityhub" {
#   source = "./modules/securityhub"
#
#   environment = var.environment
#   aws_region  = local.region
#
#   depends_on = [
#     module.guardduty,
#     module.config
#   ]
# }

# ============================================================
# Amazon Inspector
# Paid vulnerability scanning service
# ============================================================

# module "inspector" {
#   source = "./modules/inspector"
#
#   environment    = var.environment
#   aws_account_id = local.account_id
#   sns_topic_arn  = module.cloudwatch.alert_sns_arn
#
#   depends_on = [
#     module.securityhub
#   ]
# }