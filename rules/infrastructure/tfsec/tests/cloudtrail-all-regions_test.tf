# Test fixtures for KIRBY-INF-012 / CALIPER-AWS-010 + CALIPER-AWS-010-B
# Rule: CloudTrail Enabled in All Regions
#
# PASS resources: must clear both checks
# FAIL resources: must trigger the annotated check code

# ─── PASS: multi-region trail, logging explicitly enabled, global events ──────
# Clears: CALIPER-AWS-010 (is_multi_region_trail = true)
#         CALIPER-AWS-010-B (enable_logging != false)
resource "aws_cloudtrail" "pass_full" {
  name                          = "audit-full-pass"
  s3_bucket_name                = "my-audit-bucket"
  is_multi_region_trail         = true
  enable_logging                = true
  include_global_service_events = true

  tags = {
    Environment = "production"
  }
}

# ─── FAIL: single-region trail — triggers CALIPER-AWS-010 ──────────────────────
resource "aws_cloudtrail" "fail_single_region" {
  name                          = "audit-single-region-fail"
  s3_bucket_name                = "my-audit-bucket"
  is_multi_region_trail         = false # FAILS CALIPER-AWS-010
  enable_logging                = true
  include_global_service_events = true

  tags = {
    Environment = "staging"
  }
}

# ─── FAIL: logging disabled — triggers CALIPER-AWS-010-B ───────────────────────
resource "aws_cloudtrail" "fail_logging_disabled" {
  name                          = "audit-logging-off-fail"
  s3_bucket_name                = "my-audit-bucket"
  is_multi_region_trail         = true
  enable_logging                = false # FAILS CALIPER-AWS-010-B
  include_global_service_events = true

  tags = {
    Environment = "staging"
  }
}

# ─── PASS: multi-region, enable_logging omitted (provider default = true) ────
# Clears: CALIPER-AWS-010 (is_multi_region_trail = true)
#         CALIPER-AWS-010-B (enable_logging absent; notEqual false passes)
resource "aws_cloudtrail" "pass_defaults" {
  name                          = "audit-defaults-pass"
  s3_bucket_name                = "my-audit-bucket"
  is_multi_region_trail         = true
  include_global_service_events = true
  # enable_logging omitted — AWS provider default is true

  tags = {
    Environment = "production"
  }
}
