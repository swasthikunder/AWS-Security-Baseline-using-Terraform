output "bucket_id" {
  description = "ID of the centralized security log archive bucket"
  value       = aws_s3_bucket.log_archive.id
}

output "bucket_arn" {
  description = "ARN of the centralized security log archive bucket"
  value       = aws_s3_bucket.log_archive.arn
}

output "bucket_name" {
  description = "Name of the centralized security log archive bucket"
  value       = aws_s3_bucket.log_archive.bucket
}

output "access_logs_bucket_id" {
  description = "ID of the S3 bucket used for access logging"
  value       = aws_s3_bucket.access_logs.id
}