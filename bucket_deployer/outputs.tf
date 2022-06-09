output "policy" {
  value = data.aws_iam_policy_document.access_bucket[0].json
}

output "id" {
  value = aws_s3_bucket.state_buckets[0].id
}
