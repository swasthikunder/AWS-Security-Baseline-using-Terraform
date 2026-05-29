# AWS Baseline Security Architecture

## 📌 Overview

This document explains the architecture and security design of the AWS Baseline Security project.

The architecture is designed to establish a secure AWS account baseline using:

* Infrastructure as Code (Terraform)
* AWS native security services
* Centralized monitoring
* Threat detection
* Governance controls
* Encryption standards
* Security automation

The goal is to simulate a real-world enterprise cloud security environment.

---

# 🏗️ High-Level Architecture

```text
                        ┌─────────────────────┐
                        │     IAM Security    │
                        │ Roles + Policies    │
                        └──────────┬──────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │   CloudTrail Logs   │
                        │  Multi-Region Audit │
                        └──────────┬──────────┘
                                   │
                ┌──────────────────┴──────────────────┐
                ▼                                     ▼
      ┌──────────────────┐                 ┌──────────────────┐
      │   S3 Log Bucket  │                 │ CloudWatch Logs  │
      │ KMS Encrypted    │                 │ Metric Filters   │
      └────────┬─────────┘                 └────────┬─────────┘
               │                                    │
               ▼                                    ▼
      ┌──────────────────┐                 ┌──────────────────┐
      │  Security Hub    │◄────────────────│ Security Alarms  │
      └────────┬─────────┘                 └────────┬─────────┘
               │                                    │
               ▼                                    ▼
      ┌──────────────────┐                 ┌──────────────────┐
      │   GuardDuty      │                 │    SNS Alerts    │
      └────────┬─────────┘                 └──────────────────┘
               │
               ▼
      ┌──────────────────┐
      │    Inspector     │
      └──────────────────┘
```

---

# 🔐 Security Components

## IAM Security

Implements:

* Security Administrator role
* Security Auditor role
* BreakGlass emergency role
* Strong password policy
* IAM Access Analyzer
* Least privilege permissions
* Explicit deny statements

Purpose:

* Reduce privilege escalation risk
* Improve visibility into permissions
* Enforce governance controls

---

## CloudTrail

CloudTrail is configured for:

* Multi-region logging
* API activity monitoring
* Security event auditing
* Log integrity validation
* CloudWatch integration

Logs are securely stored in:

* Versioned S3 buckets
* KMS-encrypted storage

---

## CloudWatch Monitoring

CloudWatch provides:

* Metric filters
* Security alarms
* Root login detection
* Unauthorized API detection
* CloudTrail tampering alerts
* Security dashboards

Alerts are delivered using SNS email notifications.

---

## Amazon GuardDuty

GuardDuty enables:

* Threat intelligence monitoring
* Suspicious activity detection
* Anomalous API detection
* Malware & credential compromise detection

GuardDuty findings are integrated into Security Hub.

---

## AWS Security Hub

Security Hub centralizes:

* Security findings
* CIS benchmark checks
* AWS Foundational Security Best Practices
* Security posture visibility

---

## AWS Config

AWS Config provides:

* Configuration tracking
* Compliance monitoring
* Resource evaluation
* Security rule enforcement

---

## Amazon Inspector

Inspector enables:

* Vulnerability scanning
* EC2 assessment
* ECR image scanning
* Lambda scanning

---

## AWS KMS

KMS provides:

* Encryption key management
* Secure log encryption
* Controlled cryptographic access
* Key deletion protection

---

# 🌐 Network Architecture

The VPC module creates:

* Custom VPC
* Public subnets
* Private subnets
* Security groups
* Flow logs
* Network ACLs

Purpose:

* Network segmentation
* Traffic visibility
* Secure workload isolation

---

# 🔄 Event Flow

## Security Monitoring Flow

```text
AWS API Call
      │
      ▼
CloudTrail
      │
      ▼
CloudWatch Logs
      │
      ▼
Metric Filters
      │
      ▼
CloudWatch Alarms
      │
      ▼
SNS Notifications
      │
      ▼
Security Team Email Alerts
```

---

# 🎯 Security Objectives

The architecture is designed to:

* Improve AWS account visibility
* Detect suspicious activity
* Protect critical logs
* Enforce security controls
* Reduce attack surface
* Support compliance monitoring
* Enable centralized monitoring
* Improve operational security posture

---