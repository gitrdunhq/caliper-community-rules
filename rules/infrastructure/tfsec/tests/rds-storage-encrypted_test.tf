# Test fixtures for KIRBY-INF-006 / CALIPER-AWS-005 — RDS Storage Encryption
# PASS: aws_db_instance with storage_encrypted = true
# FAIL: aws_db_instance with storage_encrypted = false or omitted

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: storage_encrypted explicitly set to true
resource "aws_db_instance" "pass_encrypted" {
  identifier     = "pass-db-encrypted"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 100
  storage_encrypted = true # PASS: encryption enabled

  backup_retention_period = 7
  username                = "dbadmin"
  password                = "change-me-via-secrets-manager"

  tags = {
    Environment = "production"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: storage_encrypted explicitly set to false
resource "aws_db_instance" "fail_not_encrypted" {
  identifier     = "fail-db-not-encrypted"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 100
  storage_encrypted = false # FAIL: encryption disabled — fails CALIPER-AWS-005

  backup_retention_period = 7
  username                = "dbadmin"
  password                = "change-me-via-secrets-manager"

  tags = {
    Environment = "staging"
  }
}

# FAIL: storage_encrypted omitted — Terraform defaults to false
resource "aws_db_instance" "fail_encryption_omitted" {
  identifier     = "fail-db-encryption-omitted"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.small"

  allocated_storage = 20
  # storage_encrypted omitted — defaults to false, fails CALIPER-AWS-005

  backup_retention_period = 7
  username                = "dbadmin"
  password                = "change-me-via-secrets-manager"

  tags = {
    Environment = "staging"
  }
}
