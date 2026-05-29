# 🔐 AWS-Security-Baseline-using-Terraform

> Enterprise-style AWS baseline security architecture built using Terraform and AWS-native security services.

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=for-the-badge\&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud_Security-FF9900?style=for-the-badge\&logo=amazonaws)](https://aws.amazon.com/)
[![Security](https://img.shields.io/badge/Security-DevSecOps-red?style=for-the-badge)](https://aws.amazon.com/security/)
[![Infrastructure as Code](https://img.shields.io/badge/IaC-Terraform-blue?style=for-the-badge)](https://developer.hashicorp.com/terraform)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

# 📌 Overview

AWS accounts are often deployed with weak default security controls, leading to:

* Lack of centralized logging
* Weak IAM governance
* No automated threat detection
* Poor visibility into suspicious activity
* Weak encryption standards
* Limited compliance monitoring
* Increased risk of privilege escalation

This project implements an enterprise-style AWS baseline security architecture using Terraform and AWS-native security services.

The goal is to simulate how organizations establish secure cloud foundations using:

* Infrastructure as Code (IaC)
* Security automation
* Centralized monitoring
* Threat detection
* Governance controls
* Cloud compliance principles
* DevSecOps practices

The architecture follows:

* AWS Well-Architected Security Pillar
* CIS AWS Foundations Benchmark
* AWS Security Reference Architecture
* Least privilege access control
* Defense-in-depth security principles

---

# 🚀 Core Features

## 🔐 IAM & Governance

* Strong IAM password policy
* Security Administrator role
* Security Auditor role
* BreakGlass emergency admin role
* IAM Access Analyzer integration
* Least privilege IAM permissions
* Explicit deny guardrails
* Root account hardening guidance

---

## 📜 Logging & Monitoring

* Multi-region CloudTrail
* CloudTrail log validation
* CloudWatch log integration
* Security metric filters
* CloudWatch alarms
* SNS alert notifications
* Security dashboards
* Centralized audit logging

---

## 🛡️ Threat Detection & Compliance

* Optional Amazon GuardDuty integration
* Optional AWS Security Hub integration
* Optional AWS Config managed rules
* Optional Amazon Inspector integration

---

## 🔒 Encryption & Data Protection

* Customer-managed KMS keys
* KMS key policies
* S3 encryption enforcement
* Versioned log storage
* S3 public access blocking
* Secure log archival

---

## 🌐 Network Security

* Custom VPC architecture
* Public/private subnet separation
* VPC Flow Logs
* Security groups
* Network ACLs
* Secure network segmentation

---

## 💰 Cost Governance

* AWS Budgets integration
* Budget threshold alerts
* Cost-aware deployment practices
* Optional deployment controls for billable services

---

# 🏗️ Security Architecture

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

# 🧠 Real-World Use Case

This project simulates securing a newly provisioned AWS environment in an enterprise setting.

The architecture focuses on:

* Improving cloud visibility
* Detecting suspicious activity
* Protecting audit logs
* Enforcing governance controls
* Reducing attack surface
* Improving operational security posture
* Centralizing security monitoring

This project can serve as:

* A Terraform portfolio project
* A cloud security learning project
* A DevSecOps practice environment
* A baseline AWS security architecture reference

---

# 🛠️ Technologies Used

| Technology       | Purpose                      |
| ---------------- | ---------------------------- |
| Terraform        | Infrastructure as Code       |
| AWS IAM          | Identity & Access Management |
| AWS CloudTrail   | Audit logging                |
| AWS CloudWatch   | Monitoring & Alerting        |
| AWS KMS          | Encryption Management        |
| AWS Config       | Compliance Monitoring        |
| AWS Security Hub | Security Posture Management  |
| Amazon GuardDuty | Threat Detection             |
| Amazon Inspector | Vulnerability Scanning       |
| AWS Budgets      | Cost Governance              |
| SNS              | Alert Notifications          |
| S3               | Secure Log Archival          |

---

# 📂 Project Structure

```text

AWS-Security-Baseline-using-Terraform/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── screenshots/
│   ├── terraform-init.png
│   ├── terraform-validate.png
│   └── terraform-plan.png
│
├── policies/
│   ├── admin-role-policy.json
│   ├── audit-role-policy.json
│   ├── kms-key-policy.json
│   └── scp-guardrails.json
│
├── scripts/
│   └── deploy.sh
│
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── .terraform.lock.hcl
    │
    └── modules/
        ├── budgets/
        ├── cloudtrail/
        ├── cloudwatch/
        ├── iam/
        ├── kms/
        ├── s3/
        ├── vpc/
        ├── config/
        ├── guardduty/
        ├── inspector/
        └── securityhub/
        
```

---

# ⚙️ Deployment Workflow

## Initialize Terraform

```bash
terraform init
```

## Validate Configuration

```bash
terraform validate
```

## Preview Infrastructure Changes

```bash
terraform plan
```

## Deploy Infrastructure (Use With Caution)
```bash
terraform apply
```

---

# For zero-cost learning and validation:

- Use `terraform validate` and `terraform plan` before deployment
- Keep NAT Gateway disabled
- Keep GuardDuty, Security Hub, Inspector, and AWS Config modules commented out
- Use AWS Budgets alerts to monitor unexpected charges
- Deploy only foundational modules during testing


# 📋 Prerequisites

Before deployment ensure:

* AWS CLI installed
* Terraform >= 1.5 installed
* AWS credentials configured
* IAM user or role with sufficient deployment permissions
* MFA enabled on the root account

Verify credentials:

```bash
aws sts get-caller-identity
```

---

# 🔒 Security Controls Implemented

| Category                 | Controls                                |
| ------------------------ | --------------------------------------- |
| IAM                      | Roles, password policy, least privilege |
| Logging                  | CloudTrail, Flow Logs, CloudWatch       |
| Monitoring               | Alarms, dashboards, SNS alerts          |
| Encryption               | KMS-managed encryption                  |
| Compliance               | AWS Config rules                        |
| Governance               | SCP guardrails                          |
| Threat Detection         | GuardDuty + Security Hub                |
| Vulnerability Management | Inspector                               |
| Cost Control             | Budgets & alerts                        |

---

# 📊 Key Security Features

| Feature             | Purpose                          |
| ------------------- | -------------------------------- |
| CloudTrail          | Audit logging and API monitoring |
| GuardDuty           | Threat detection                 |
| Security Hub        | Centralized security findings    |
| CloudWatch          | Monitoring and alerting          |
| AWS Config          | Compliance monitoring            |
| KMS                 | Encryption and key management    |
| IAM Access Analyzer | Permission visibility            |
| SNS                 | Alert notifications              |

---

# 💸 Cost Awareness

This project includes AWS services that may generate charges outside the AWS Free Tier.

## Potentially Billable Services

| Service     | Notes                                        |
| ----------- | -------------------------------------------- |
|Security Hub | Charges may apply for standards evaluations  |
| GuardDuty   | Charges after free trial                     |
| Inspector   | Charges for vulnerability scans              |
| AWS Config  | Charges per recorded configuration item      |
| NAT Gateway | Expensive if enabled                         |

## Recommended Low-Cost Deployment

For learning purposes:

* Keep advanced security modules commented out for zero-cost testing
* Disable NAT Gateway
* Avoid long-term GuardDuty usage
* Avoid long-term Inspector usage
* Use `terraform plan` before `terraform apply`
* Configure AWS Budgets alerts

---

# 🧠 Skills Demonstrated

* AWS Cloud Security
* Terraform & Infrastructure as Code
* DevSecOps Practices
* IAM Governance
* Security Monitoring
* Threat Detection
* Encryption Architecture
* Compliance Monitoring
* Cloud Logging & Alerting
* Security Automation

---

# 🏆 Resume Highlights

* Designed and implemented an enterprise-style AWS baseline security architecture using Terraform and AWS-native security services.
* Automated IAM governance, centralized logging, encryption, threat detection, and compliance monitoring.
* Implemented CloudTrail, GuardDuty, Security Hub, AWS Config, and KMS-based encryption workflows.
* Built modular Infrastructure-as-Code architecture using reusable Terraform modules.
* Developed security guardrails, least privilege IAM policies, and monitoring dashboards.

---

# 🚧 Future Enhancements

Potential future improvements:

* Multi-account AWS Organizations deployment
* CI/CD pipeline integration
* Lambda-based remediation
* SIEM integration
* WAF integration
* Cross-account logging
* Automated drift detection
* EKS/ECS security controls

---

# 👥 Contributors

* **Sakshat S** — Project Lead, Development & Security Engineering
* **Swasthi Kunder** — Contributor (Testing & Research)

---

# ⭐ Final Notes

This project was built to demonstrate how Infrastructure as Code and AWS-native services can be combined to establish secure cloud foundations using real-world cloud security principles.

The focus is not only deployment automation, but also:

* Security visibility
* Governance
* Threat monitoring
* Compliance awareness
* Operational resilience
* Secure cloud engineering practices

If you found this project useful, consider giving it a ⭐ on GitHub.
