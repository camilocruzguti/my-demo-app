# DATA #
data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
# RESOURCES #
resource "aws_s3_bucket" "state_buckets" {
  count         = var.bucket_count
  bucket        = "${var.bucket_base_name}-${var.bucket_suffix[count.index]}"
  force_destroy = true
  tags = {
    "Name" = "EKS-state_bucket-tracker"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.bucket_count
  bucket = aws_s3_bucket.state_buckets[count.index].id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policies" {
  count  = var.bucket_count
  bucket = aws_s3_bucket.state_buckets[count.index].id
  policy = data.aws_iam_policy_document.access_bucket[count.index].json
}


data "aws_iam_policy_document" "access_bucket" {
  count = var.bucket_count
  statement {
    principals {
      identifiers = ["${data.aws_caller_identity.current.arn}"]
      type        = "AWS"
    }
    effect  = "Allow"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::${var.bucket_base_name}-${var.bucket_suffix[count.index]}/*",
    "arn:aws:s3:::${var.bucket_base_name}-${var.bucket_suffix[count.index]}"]
  }

}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  count  = var.bucket_count
  bucket = aws_s3_bucket.state_buckets[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
