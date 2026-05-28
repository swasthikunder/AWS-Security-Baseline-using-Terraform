output "log_key_arn" {
  description = "ARN of the KMS key used for security log encryption"
  value       = aws_kms_key.logs.arn
}

output "log_key_id" {
  description = "ID of the KMS key used for security log encryption"
  value       = aws_kms_key.logs.key_id
}

output "s3_key_arn" {
  description = "ARN of the KMS key used for S3 data encryption"
  value       = aws_kms_key.s3_data.arn
}

output "s3_key_id" {
  description = "ID of the KMS key used for S3 data encryption"
  value       = aws_kms_key.s3_data.key_id
}