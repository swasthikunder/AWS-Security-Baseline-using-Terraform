# AWS Cost Optimization Guide

## 📌 Overview

This project uses several AWS security services.

Some services may generate charges outside the AWS Free Tier.

This guide explains:

* Which services can cost money
* How to reduce charges
* How to safely learn AWS security
* How to avoid unexpected billing

---

# 💰 Potentially Billable Services

| Service     | Cost Risk | Notes                                   |
| ----------- | --------- | --------------------------------------- |
| GuardDuty   | Medium    | Free trial expires after 30 days        |
| Inspector   | Medium    | Charges for vulnerability scans         |
| AWS Config  | Medium    | Charges per recorded configuration item |
| NAT Gateway | HIGH      | Expensive even when idle                |
| CloudWatch  | Low       | Logs and alarms can scale               |
| KMS         | Low       | Monthly key charges                     |
| CloudTrail  | Low       | Data events may increase costs          |

---

# 🚨 Biggest Cost Trap

## NAT Gateway

NAT Gateways are one of the most expensive networking resources for beginners.

Estimated cost:

* ~$32/month per NAT Gateway
* Additional data processing charges

## Recommendation

Disable NAT Gateways unless absolutely necessary.

Terraform example:

```hcl
enable_nat_gateway = false
```

---

# 🔒 Low-Cost Deployment Strategy

## Recommended Services to Deploy

Safe and low-cost:

* IAM
* CloudTrail
* S3
* CloudWatch
* SNS
* KMS

---

## Services Recommended for Learning Only

Deploy temporarily only:

* GuardDuty
* Inspector
* Config

Destroy them after testing.

---

# 💡 Recommended Terraform Workflow

## Validate Configuration

```bash
terraform validate
```

---

## Preview Infrastructure

```bash
terraform plan
```

---

## Apply Infrastructure Carefully

```bash
terraform apply
```

Only apply resources you truly need.

---

# 📉 Budget Protection

The project includes AWS Budgets integration.

Recommended budget setup:

| Setting         | Value     |
| --------------- | --------- |
| Monthly Budget  | $1–5      |
| Alert Threshold | 50%       |
| Alert Method    | Email SNS |

---

# 🧠 Cost-Aware Learning Advice

When learning AWS:

* Always destroy unused resources
* Avoid leaving services idle
* Monitor billing dashboard frequently
* Use terraform destroy after testing
* Prefer architecture understanding over full deployments

---

# 🛑 Recommended Disabled Services for Zero-Cost Learning

If avoiding charges entirely:

Disable:

* GuardDuty
* Inspector
* Config
* NAT Gateway

Keep only:

* IAM
* S3
* CloudTrail
* CloudWatch
* SNS
* KMS

---