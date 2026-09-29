output "bucket_name" {
  description = "Bucket Name"
  value       = aws_s3_bucket.elif-tfstate-5247.id
}

output "role_arn" {
  description = "Role Arn"
  value       = aws_iam_openid_connect_provider.default.arn
}