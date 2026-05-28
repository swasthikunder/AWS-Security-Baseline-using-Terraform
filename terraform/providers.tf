terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # ============================================================
  # OPTIONAL REMOTE STATE BACKEND
  # Uncomment for team/production environments
  # ============================================================

  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "baseline-security/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# ============================================================
# AWS Provider
# ============================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-baseline-security"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner_email
    }
  }
}