output "vpc_id" {
  description = "ID of the baseline VPC"
  value       = aws_vpc.baseline.id
}

output "vpc_cidr" {
  description = "CIDR block of the baseline VPC"
  value       = aws_vpc.baseline.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "management_sg_id" {
  description = "ID of the management security group"
  value       = aws_security_group.management.id
}