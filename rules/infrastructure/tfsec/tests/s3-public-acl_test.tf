# Test fixtures for KIRBY-INF-015 — S3 Public ACL (CALIPER-AWS-013 / 013-WRITE / 013-AUTH)
# PASS: aws_s3_bucket_acl with a private or non-public canned ACL
# FAIL: aws_s3_bucket_acl with public-read, public-read-write, or authenticated-read

# --------------------------------------------------------------------------
# PASS cases — compliant ACL values
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "pass_private" {
  bucket = "example-bucket-private-acl"
}

# PASS: explicit private ACL — default and most restrictive canned ACL
resource "aws_s3_bucket_acl" "pass_private" {
  bucket = aws_s3_bucket.pass_private.id
  acl    = "private"
}

resource "aws_s3_bucket" "pass_owner_full" {
  bucket = "example-bucket-owner-full-acl"
}

# PASS: bucket-owner-full-control ACL — grants full control only to the bucket owner account
resource "aws_s3_bucket_acl" "pass_owner_full" {
  bucket = aws_s3_bucket.pass_owner_full.id
  acl    = "bucket-owner-full-control"
}

resource "aws_s3_bucket" "pass_owner_read" {
  bucket = "example-bucket-owner-read-acl"
}

# PASS: bucket-owner-read ACL — grants read to the bucket owner, not the public
resource "aws_s3_bucket_acl" "pass_owner_read" {
  bucket = aws_s3_bucket.pass_owner_read.id
  acl    = "bucket-owner-read"
}

resource "aws_s3_bucket" "pass_log_delivery" {
  bucket = "example-bucket-log-delivery-acl"
}

# PASS: log-delivery-write ACL — allows S3 log delivery service to write access logs
resource "aws_s3_bucket_acl" "pass_log_delivery" {
  bucket = aws_s3_bucket.pass_log_delivery.id
  acl    = "log-delivery-write"
}

# --------------------------------------------------------------------------
# FAIL cases — forbidden public ACL values
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "fail_public_read" {
  bucket = "example-bucket-public-read-fail"
}

# FAIL: CALIPER-AWS-013 — public-read exposes all objects to unauthenticated internet users
resource "aws_s3_bucket_acl" "fail_public_read" {
  bucket = aws_s3_bucket.fail_public_read.id
  acl    = "public-read" # FAIL: grants read access to the entire internet
}

resource "aws_s3_bucket" "fail_public_read_write" {
  bucket = "example-bucket-public-rw-fail"
}

# FAIL: CALIPER-AWS-013-WRITE — public-read-write allows anyone to read, write, or delete objects
resource "aws_s3_bucket_acl" "fail_public_read_write" {
  bucket = aws_s3_bucket.fail_public_read_write.id
  acl    = "public-read-write" # FAIL: grants full read/write to all internet users
}

resource "aws_s3_bucket" "fail_authenticated_read" {
  bucket = "example-bucket-auth-read-fail"
}

# FAIL: CALIPER-AWS-013-AUTH — authenticated-read grants read to all authenticated AWS accounts worldwide
resource "aws_s3_bucket_acl" "fail_authenticated_read" {
  bucket = aws_s3_bucket.fail_authenticated_read.id
  acl    = "authenticated-read" # FAIL: any authenticated AWS account globally can read this bucket
}
