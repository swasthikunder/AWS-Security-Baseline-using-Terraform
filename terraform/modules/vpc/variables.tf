variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the baseline VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones used for subnet deployment"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways (can incur charges)"
  type        = bool
  default     = false
}

variable "flow_log_role_arn" {
  description = "IAM role ARN used for VPC Flow Logs"
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for VPC Flow Logs"
  type        = number
}