# Test fixtures for KIRBY-INF-008 / CALIPER-AWS-006 — S3 Bucket Server-Side Encryption
# PASS: aws_s3_bucket_server_side_encryption_configuration with rule.apply_server_side_encryption_by_default
# FAIL: resource absent or rule block missing apply_server_side_encryption_by_default

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "pass_sse_s3" {
  bucket = "example-bucket-sse-s3-pass"
}

# PASS: SSE-S3 (AES256) server-side encryption configured
resource "aws_s3_bucket_server_side_encryption_configuration" "pass_sse_s3" {
  bucket = aws_s3_bucket.pass_sse_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "pass_sse_kms" {
  bucket = "example-bucket-sse-kms-pass"
}

# PASS: SSE-KMS server-side encryption configured (preferred for regulated workloads)
resource "aws_s3_bucket_server_side_encryption_configuration" "pass_sse_kms" {
  bucket = aws_s3_bucket.pass_sse_kms.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"
    }
    bucket_key_enabled = true
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "fail_no_sse" {
  bucket = "example-bucket-no-sse-fail"
  # No aws_s3_bucket_server_side_encryption_configuration resource — fails CALIPER-AWS-006
}

resource "aws_s3_bucket" "fail_empty_rule" {
  bucket = "example-bucket-empty-rule-fail"
}

# FAIL: rule block exists but apply_server_side_encryption_by_default is absent
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_empty_rule" {
  bucket = aws_s3_bucket.fail_empty_rule.id

  rule {
    # apply_server_side_encryption_by_default omitted — fails CALIPER-AWS-006
    bucket_key_enabled = true
  }
}
