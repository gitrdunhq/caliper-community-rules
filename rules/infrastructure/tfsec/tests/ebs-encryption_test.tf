# Test fixtures for KIRBY-INF-011 / EEDOM-AWS-009 — EBS Volume Encryption
# PASS: aws_ebs_volume with encrypted = true
# FAIL: aws_ebs_volume with encrypted = false or encrypted omitted

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: EBS volume encrypted with the default AWS-managed key
resource "aws_ebs_volume" "pass_encrypted_default_key" {
  availability_zone = "us-east-1a"
  size              = 100
  type              = "gp3"
  encrypted         = true # PASS: encryption enabled

  tags = {
    Name        = "pass-data-volume"
    Environment = "production"
  }
}

# PASS: EBS volume encrypted with a customer-managed KMS key (preferred for regulated workloads)
resource "aws_ebs_volume" "pass_encrypted_cmk" {
  availability_zone = "us-east-1a"
  size              = 500
  type              = "io2"
  iops              = 10000
  encrypted         = true # PASS: encryption enabled
  kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/example-cmk-id"

  tags = {
    Name        = "pass-data-volume-cmk"
    Environment = "production"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: encryption explicitly disabled
resource "aws_ebs_volume" "fail_encryption_disabled" {
  availability_zone = "us-east-1a"
  size              = 100
  type              = "gp3"
  encrypted         = false # FAIL: encryption must be true — fails EEDOM-AWS-009

  tags = {
    Name        = "fail-data-volume-disabled"
    Environment = "staging"
  }
}

# FAIL: encrypted attribute omitted — AWS defaults to false unless account-level encryption
# is enforced separately (which Terraform cannot guarantee at the resource level)
resource "aws_ebs_volume" "fail_encryption_omitted" {
  availability_zone = "us-east-1a"
  size              = 50
  type              = "gp2"
  # encrypted omitted — Terraform default is false, fails EEDOM-AWS-009

  tags = {
    Name        = "fail-data-volume-omitted"
    Environment = "staging"
  }
}
