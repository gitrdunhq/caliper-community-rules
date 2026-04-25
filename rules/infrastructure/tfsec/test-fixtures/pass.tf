# Terraform that passes all eedom custom tfsec checks
# EEDOM-AWS-001: S3 versioning enabled
# EEDOM-AWS-002: RDS backup retention >= 7 days
# EEDOM-AWS-003: CloudWatch log group retention set

resource "aws_s3_bucket" "data" {
  bucket = "my-app-data-bucket"

  versioning {
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_db_instance" "primary" {
  identifier     = "my-app-primary"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 100
  storage_encrypted = true

  backup_retention_period = 14
  backup_window           = "03:00-04:00"

  tags = {
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/app/production"
  retention_in_days = 90

  tags = {
    Environment = "production"
  }
}
