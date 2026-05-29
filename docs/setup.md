# AWS Security Project Setup Guide

## 📌 Overview

This guide explains how to set up and run the AWS Baseline Security project.

---

# 🛠️ Prerequisites

Install the following:

## Required Tools

| Tool             | Purpose                         |
| ---------------- | ------------------------------- |
| Terraform >= 1.0 | Infrastructure provisioning     |
| AWS CLI v2       | AWS authentication & management |
| Git              | Repository management           |
| Git Bash         | Recommended terminal on Windows |

---

# 🔑 Configure AWS CLI

Run:

```bash
aws configure
```

Provide:

* AWS Access Key
* AWS Secret Key
* Region
* Output format

Verify:

```bash
aws sts get-caller-identity
```

---

# 📂 Clone Repository

```bash
git clone <repository-url>
cd aws-security-project
```

---

# ⚙️ Terraform Initialization

Initialize Terraform:

```bash
terraform init
```

---

# ✅ Validate Terraform

```bash
terraform validate
```

This checks:

* syntax errors
* missing variables
* invalid resources
* provider issues

---

# 📋 Preview Infrastructure

```bash
terraform plan
```

This shows:

* resources to create
* configuration changes
* estimated infrastructure actions

---

# 🚀 Deploy Infrastructure

```bash
terraform apply
```

Terraform will ask for confirmation before deployment.

---

# 🧹 Destroy Infrastructure

To avoid charges:

```bash
terraform destroy
```

---

# 🔒 Recommended Beginner Deployment

To minimize AWS costs:

Deploy only:

* IAM
* CloudTrail
* S3
* CloudWatch
* SNS
* KMS

Avoid:

* GuardDuty
* Inspector
* Config
* NAT Gateway

---

# 🧠 Windows Users

Recommended terminal:

* Git Bash

Avoid mixing:

* PowerShell commands
* Bash commands

---

# 📌 Common Terraform Commands

## Format Terraform Files

```bash
terraform fmt
```

---

## Validate Terraform

```bash
terraform validate
```

---

## View Terraform State

```bash
terraform state list
```

---

## Destroy Resources

```bash
terraform destroy
```

---

# 🚨 Troubleshooting

## Error: Provider not installed

Fix:

```bash
terraform init
```

---

## Error: AWS credentials not configured

Fix:

```bash
aws configure
```

---

## Error: Access Denied

Fix:

Ensure IAM user has:

* AdministratorAccess
  OR
* required permissions for services used

---

## Error: Billing concerns

Fix:

* destroy resources immediately
* disable expensive services
* monitor AWS Billing Dashboard

---

# 🎯 Recommended Workflow

```text
terraform init
      ↓
terraform validate
      ↓
terraform plan
      ↓
terraform apply
      ↓
terraform destroy
```

---

# ✅ Final Notes

This project is intended for:

* Cloud security learning
* Terraform practice
* DevSecOps portfolio building
* AWS security experimentation
* Infrastructure as Code practice

Always monitor AWS billing while testing cloud resources.
