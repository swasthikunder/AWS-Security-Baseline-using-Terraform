# ============================================================
# VPC Module — Network Isolation and Flow Logs
# Improved Enterprise-Style Version
# ============================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "baseline" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-baseline-security-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "baseline" {
  vpc_id = aws_vpc.baseline.id

  tags = {
    Name        = "${var.environment}-baseline-security-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Public Subnets
# ============================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.baseline.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Type        = "Public"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Private Subnets
# ============================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.baseline.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Type        = "Private"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# NAT Gateway (OPTIONAL — CAN INCUR CHARGES)
# Keep disabled for ₹0-safe deployments
# ============================================================

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_nat_gateway" "baseline" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gw-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_internet_gateway.baseline
  ]
}

# ============================================================
# Public Route Table
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.baseline.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.baseline.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Private Route Tables
# ============================================================

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.baseline.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.baseline[count.index].id
    }
  }

  tags = {
    Name        = "${var.environment}-private-rt-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Route Table Associations
# ============================================================

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================
# Default Security Group — Deny All
# ============================================================

resource "aws_default_security_group" "baseline" {
  vpc_id = aws_vpc.baseline.id

  tags = {
    Name        = "${var.environment}-default-sg-deny-all"
    Warning     = "DO NOT USE — denies all traffic"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Management Security Group
# ============================================================

resource "aws_security_group" "management" {
  name        = "${var.environment}-management-sg"
  description = "Baseline management security group — least privilege outbound only"
  vpc_id      = aws_vpc.baseline.id

  egress {
    description = "Allow HTTPS to AWS APIs"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    description = "Allow DNS"

    from_port = 53
    to_port   = 53
    protocol  = "udp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name        = "${var.environment}-management-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# VPC Flow Logs
# ============================================================

resource "aws_flow_log" "vpc" {
  vpc_id       = aws_vpc.baseline.id
  traffic_type = "ALL"

  iam_role_arn = var.flow_log_role_arn

  log_destination_type = "cloud-watch-logs"

  log_destination = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/baseline-flow-logs"

  tags = {
    Name        = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Network ACL — Private Subnet Protection
# ============================================================

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.baseline.id
  subnet_ids = aws_subnet.private[*].id

  # Block SSH
  ingress {
    protocol = "tcp"
    rule_no  = 100
    action   = "deny"

    cidr_block = "0.0.0.0/0"

    from_port = 22
    to_port   = 22
  }

  # Block RDP
  ingress {
    protocol = "tcp"
    rule_no  = 110
    action   = "deny"

    cidr_block = "0.0.0.0/0"

    from_port = 3389
    to_port   = 3389
  }

  # Allow remaining traffic
  ingress {
    protocol = "-1"
    rule_no  = 200
    action   = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 0
    to_port   = 0
  }

  egress {
    protocol = "-1"
    rule_no  = 100
    action   = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 0
    to_port   = 0
  }

  tags = {
    Name        = "${var.environment}-private-nacl"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}