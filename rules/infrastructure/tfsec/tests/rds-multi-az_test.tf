# Test fixtures for KIRBY-INF-026 / EEDOM-AWS-014 — Multi-AZ RDS
# PASS: aws_db_instance with multi_az = true
# FAIL: aws_db_instance with multi_az = false or attribute omitted

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: production RDS instance with Multi-AZ enabled
resource "aws_db_instance" "pass_multi_az_enabled" {
  identifier              = "pass-prod-postgres"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.t3.medium"
  allocated_storage       = 100
  storage_encrypted       = true
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = 7
  deletion_protection     = true

  multi_az = true # PASS: Multi-AZ enabled — satisfies EEDOM-AWS-014

  tags = {
    Environment = "production"
  }
}

# PASS: MySQL read-replica configuration with Multi-AZ on the primary
resource "aws_db_instance" "pass_mysql_multi_az" {
  identifier        = "pass-prod-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.r6g.large"
  allocated_storage = 200
  storage_encrypted = true
  username          = "dbadmin"
  password          = var.db_password

  multi_az = true # PASS: Multi-AZ standby ensures automatic failover

  tags = {
    Environment = "production"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: Multi-AZ explicitly disabled — single point of failure in one AZ
resource "aws_db_instance" "fail_multi_az_false" {
  identifier        = "fail-staging-postgres"
  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t3.small"
  allocated_storage = 20
  username          = "admin"
  password          = var.db_password

  multi_az = false # FAIL: single-AZ — no automatic failover — fails EEDOM-AWS-014

  tags = {
    Environment = "staging"
  }
}

# FAIL: multi_az attribute omitted — AWS default is false for non-Aurora RDS instances
resource "aws_db_instance" "fail_multi_az_omitted" {
  identifier        = "fail-dev-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password          = var.db_password
  # multi_az omitted — defaults to false, no HA — fails EEDOM-AWS-014

  tags = {
    Environment = "development"
  }
}
