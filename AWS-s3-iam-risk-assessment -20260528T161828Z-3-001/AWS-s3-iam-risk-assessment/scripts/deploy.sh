#!/usr/bin/env bash

# ============================================================
# AWS Baseline Security — Deployment Script
# ₹0-SAFE ENTERPRISE VERSION
#
# Usage:
# ALERT_EMAIL=you@example.com ./scripts/deploy.sh
# ============================================================

set -euo pipefail

# ============================================================
# Terminal Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================
# Environment Variables
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

STACK_NAME="${STACK_NAME:-aws-baseline-security}"

DEPLOYMENT_TYPE="${DEPLOYMENT_TYPE:-terraform}"

AWS_REGION="${AWS_REGION:-us-east-1}"

ALERT_EMAIL="${ALERT_EMAIL:-}"

MONTHLY_BUDGET="${MONTHLY_BUDGET:-5}"

ENVIRONMENT="${ENVIRONMENT:-sandbox}"

# ============================================================
# Logging Functions
# ============================================================

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

# ============================================================
# Check Prerequisites
# ============================================================

check_prerequisites() {

  log_section "Checking Prerequisites"

  # ============================================================
  # AWS CLI
  # ============================================================

  if ! command -v aws &>/dev/null; then
    log_error "AWS CLI not installed."
    exit 1
  fi

  log_info "AWS CLI detected"

  # ============================================================
  # AWS Credentials
  # ============================================================

  if ! aws sts get-caller-identity &>/dev/null; then
    log_error "AWS credentials not configured."
    exit 1
  fi

  ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

  log_info "AWS Account ID: ${ACCOUNT_ID}"
  log_info "AWS Region: ${AWS_REGION}"

  # ============================================================
  # Alert Email
  # ============================================================

  if [ -z "$ALERT_EMAIL" ]; then
    read -rp "Enter alert email address: " ALERT_EMAIL
  fi

  if [ -z "$ALERT_EMAIL" ]; then
    log_error "Alert email is required."
    exit 1
  fi

  # ============================================================
  # Terraform
  # ============================================================

  if [ "$DEPLOYMENT_TYPE" == "terraform" ]; then

    if ! command -v terraform &>/dev/null; then
      log_error "Terraform not installed."
      exit 1
    fi

    log_info "Terraform detected"
    terraform version | head -1
  fi

  log_info "All prerequisites satisfied"
}

# ============================================================
# Pre-Deployment Checks
# ============================================================

pre_deployment_checks() {

  log_section "Running Pre-Deployment Checks"

  # ============================================================
  # Root Access Key Check
  # ============================================================

  aws iam generate-credential-report &>/dev/null || true

  sleep 3

  REPORT=$(
    aws iam get-credential-report \
      --query 'Content' \
      --output text 2>/dev/null \
      | base64 -d 2>/dev/null || echo ""
  )

  if echo "$REPORT" | grep -q "^<root_account>"; then

    ROOT_KEY=$(
      echo "$REPORT" \
      | grep "^<root_account>" \
      | cut -d',' -f9
    )

    if [ "$ROOT_KEY" == "true" ]; then
      log_warn "ROOT ACCOUNT HAS ACTIVE ACCESS KEYS"
      log_warn "Delete root access keys immediately"
    else
      log_info "Root account has no active access keys"
    fi
  fi

  # ============================================================
  # Existing CloudTrail Check
  # ============================================================

  TRAILS=$(
    aws cloudtrail describe-trails \
      --query 'trailList[*].Name' \
      --output text 2>/dev/null || echo ""
  )

  if [ -n "$TRAILS" ]; then
    log_warn "Existing CloudTrail trails detected:"
    echo "$TRAILS"
  fi

  # ============================================================
  # Cost Warning
  # ============================================================

  log_warn "NAT Gateway remains disabled for ₹0-safe deployment"

  log_info "Pre-deployment checks completed"
}

# ============================================================
# Terraform Deployment
# ============================================================

deploy_terraform() {

  log_section "Deploying Infrastructure with Terraform"

  cd "$PROJECT_ROOT/terraform"

  # ============================================================
  # Generate terraform.tfvars
  # ============================================================

  cat > terraform.tfvars << EOF
aws_region           = "${AWS_REGION}"
environment          = "${ENVIRONMENT}"
alert_email          = "${ALERT_EMAIL}"
owner_email          = "${ALERT_EMAIL}"
monthly_budget_limit = "${MONTHLY_BUDGET}"
EOF

  log_info "Generated terraform.tfvars"

  # ============================================================
  # Terraform Format
  # ============================================================

  terraform fmt -recursive

  # ============================================================
  # Terraform Init
  # ============================================================

  terraform init

  # ============================================================
  # Terraform Validate
  # ============================================================

  terraform validate

  # ============================================================
  # Terraform Plan
  # ============================================================

  terraform plan \
    -var-file="terraform.tfvars" \
    -out="baseline.tfplan"

  # ============================================================
  # Apply Confirmation
  # ============================================================

  echo ""
  log_warn "Review the Terraform plan carefully before applying."
  log_warn "Only foundational ₹0-safe modules are enabled."

  read -rp "Proceed with apply? (yes/no): " CONFIRM

  if [ "$CONFIRM" != "yes" ]; then
    log_warn "Deployment cancelled."
    exit 0
  fi

  # ============================================================
  # Terraform Apply
  # ============================================================

  terraform apply "baseline.tfplan"

  log_info "Terraform deployment completed successfully"

  # ============================================================
  # Terraform Outputs
  # ============================================================

  terraform output
}

# ============================================================
# CloudFormation Deployment
# ============================================================

deploy_cloudformation() {

  log_section "Deploying Infrastructure with CloudFormation"

  cd "$PROJECT_ROOT/cloudformation"

  # ============================================================
  # Validate Template
  # ============================================================

  aws cloudformation validate-template \
    --template-body "file://master-stack.yaml" \
    --region "$AWS_REGION"

  # ============================================================
  # Deploy Stack
  # ============================================================

  aws cloudformation deploy \
    --template-file master-stack.yaml \
    --stack-name "$STACK_NAME" \
    --region "$AWS_REGION" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
      AlertEmail="$ALERT_EMAIL" \
      OwnerEmail="$ALERT_EMAIL" \
      MonthlyBudgetLimit="$MONTHLY_BUDGET" \
      Environment="$ENVIRONMENT" \
    --no-fail-on-empty-changeset

  # ============================================================
  # Stack Outputs
  # ============================================================

  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$AWS_REGION" \
    --query 'Stacks[0].Outputs' \
    --output table

  log_info "CloudFormation deployment completed successfully"
}

# ============================================================
# Post Deployment Instructions
# ============================================================

post_deployment_steps() {

  log_section "Post-Deployment Steps"

  echo -e "${YELLOW}Complete the following manual security steps:${NC}"
  echo ""

  echo "1. ENABLE ROOT MFA"
  echo "   IAM → Security Credentials → MFA"

  echo ""
  echo "2. CONFIRM EMAIL SUBSCRIPTIONS"
  echo "   Check your inbox for SNS confirmation emails"

  echo ""
  echo "3. VERIFY CLOUDTRAIL LOGGING"
  echo "   CloudTrail → Trails → Verify logging is active"

  echo ""
  echo "4. VERIFY BUDGET ALERTS"
  echo "   AWS Budgets → Confirm alerts are configured"

  echo ""
  echo "5. REVIEW IAM USERS"
  echo "   Ensure MFA is enabled for all IAM users"

  echo ""
  echo "6. REVIEW TERRAFORM OUTPUTS"
  echo "   Confirm KMS, S3, IAM, and CloudTrail resources"

  echo ""

  log_info "Deployment completed successfully"
}

# ============================================================
# Main Execution
# ============================================================

log_section "AWS Baseline Security Deployment"

check_prerequisites

pre_deployment_checks

case "$DEPLOYMENT_TYPE" in

  terraform)
    deploy_terraform
    ;;

  cloudformation)
    deploy_cloudformation
    ;;

  *)
    log_error "Unknown deployment type: $DEPLOYMENT_TYPE"
    log_error "Valid options: terraform | cloudformation"
    exit 1
    ;;

esac

post_deployment_steps