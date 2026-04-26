# Terraform that FAILS all eedom custom tfsec checks
# EEDOM-AWS-001: S3 versioning missing (no aws_s3_bucket_versioning resource)
# EEDOM-AWS-002: RDS backup retention too short (1 day)
# EEDOM-AWS-003: CloudWatch log group retention not set

resource "aws_s3_bucket" "fail_data" {
  bucket = "my-app-data-bucket-fail"

  # No aws_s3_bucket_versioning resource -- fails EEDOM-AWS-001

  tags = {
    Environment = "staging"
  }
}

resource "aws_db_instance" "fail_primary" {
  identifier     = "my-app-primary-fail"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 100
  storage_encrypted = true

  backup_retention_period = 1 # Only 1 day -- fails EEDOM-AWS-002
  backup_window           = "03:00-04:00"

  tags = {
    Environment = "staging"
  }
}

resource "aws_cloudwatch_log_group" "fail_app_logs" {
  name = "/app/staging"

  # No retention_in_days -- fails EEDOM-AWS-003
  # Defaults to infinite retention

  tags = {
    Environment = "staging"
  }
}
