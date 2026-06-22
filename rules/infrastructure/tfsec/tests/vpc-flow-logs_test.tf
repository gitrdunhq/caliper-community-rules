# Test fixtures for KIRBY-INF-010 / CALIPER-AWS-008 — VPC Flow Logs Enabled
# PASS: aws_flow_log resource with vpc_id attribute present
# FAIL: aws_flow_log resource with vpc_id absent (subnet/eni-scoped only, or malformed)
#
# NOTE: tfsec custom checks cannot validate that every aws_vpc has a corresponding
# aws_flow_log. This check verifies that VPC-scoped flow log resources are well-formed.

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

resource "aws_vpc" "pass_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "pass-vpc"
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "pass_flow_logs" {
  name              = "/vpc/pass-flow-logs"
  retention_in_days = 90
}

# PASS: VPC flow log with vpc_id present, destination configured
resource "aws_flow_log" "pass_vpc_flow_log" {
  vpc_id          = aws_vpc.pass_vpc.id # PASS: vpc_id present
  traffic_type    = "ALL"
  iam_role_arn    = "arn:aws:iam::123456789012:role/vpc-flow-log-role"
  log_destination = aws_cloudwatch_log_group.pass_flow_logs.arn

  tags = {
    Environment = "production"
  }
}

resource "aws_vpc" "pass_vpc_s3" {
  cidr_block = "10.1.0.0/16"
}

# PASS: VPC flow log delivered to S3 instead of CloudWatch Logs
resource "aws_flow_log" "pass_vpc_flow_log_s3" {
  vpc_id               = aws_vpc.pass_vpc_s3.id # PASS: vpc_id present
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::example-flow-logs-bucket/vpc/"
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: aws_flow_log scoped to a subnet (subnet_id only, no vpc_id)
# This represents a gap — not all traffic is captured at the VPC level
resource "aws_flow_log" "fail_subnet_only" {
  subnet_id            = "subnet-00000000000000001" # FAIL: no vpc_id — fails CALIPER-AWS-008
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::example-flow-logs-bucket/subnet/"
}

# FAIL: aws_flow_log scoped to a network interface only (no vpc-level coverage)
resource "aws_flow_log" "fail_eni_only" {
  eni_id               = "eni-00000000000000001" # FAIL: no vpc_id — fails CALIPER-AWS-008
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::example-flow-logs-bucket/eni/"
}
