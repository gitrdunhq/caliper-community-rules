# Test fixtures for KIRBY-INF-005 / CALIPER-AWS-004 — S3 Public Access Block
# PASS: aws_s3_bucket_public_access_block with all four flags set to true
# FAIL: aws_s3_bucket_public_access_block with one or more flags missing or false

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "pass_data" {
  bucket = "example-bucket-pass"
}

# PASS: all four public access block flags set to true
resource "aws_s3_bucket_public_access_block" "pass_complete" {
  bucket = aws_s3_bucket.pass_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "fail_data" {
  bucket = "example-bucket-fail"
}

# FAIL: block_public_acls is false — partial configuration does not satisfy CALIPER-AWS-004
resource "aws_s3_bucket_public_access_block" "fail_partial_acls" {
  bucket = aws_s3_bucket.fail_data.id

  block_public_acls       = false # FAIL: must be true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "fail_data2" {
  bucket = "example-bucket-fail-2"
}

# FAIL: restrict_public_buckets missing (omitted attributes default to false in Terraform)
resource "aws_s3_bucket_public_access_block" "fail_missing_restrict" {
  bucket = aws_s3_bucket.fail_data2.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  # restrict_public_buckets omitted — defaults to false, fails CALIPER-AWS-004
}
