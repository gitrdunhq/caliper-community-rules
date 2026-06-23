# Terraform that passes all caliper custom tfsec checks
# CALIPER-AWS-001: S3 versioning enabled (via aws_s3_bucket_versioning resource)
# CALIPER-AWS-002: RDS backup retention >= 7 days
# CALIPER-AWS-003: CloudWatch log group retention set

resource "aws_s3_bucket" "pass_data" {
  bucket = "my-app-data-bucket-pass"

  tags = {
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "pass_data" {
  bucket = aws_s3_bucket.pass_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_db_instance" "pass_primary" {
  identifier     = "my-app-primary-pass"
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

resource "aws_cloudwatch_log_group" "pass_app_logs" {
  name              = "/app/production"
  retention_in_days = 90

  tags = {
    Environment = "production"
  }
}
