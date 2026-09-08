output "bucket_name" {
  value = aws_s3_bucket.raw_data.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.raw_data.arn
}

output "kms_key_arn" {
  value = aws_kms_key.data.arn
}

output "kms_key_id" {
  value = aws_kms_key.data.key_id
}