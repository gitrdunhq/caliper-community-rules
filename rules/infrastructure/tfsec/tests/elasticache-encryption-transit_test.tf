# Test fixtures for KIRBY-INF-028 / CALIPER-AWS-016 — ElastiCache Encryption in Transit
# PASS: aws_elasticache_replication_group with transit_encryption_enabled = true
# FAIL: aws_elasticache_replication_group with transit_encryption_enabled = false or attribute omitted

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: Redis replication group with TLS enabled
resource "aws_elasticache_replication_group" "pass_tls_enabled" {
  replication_group_id = "pass-redis-prod"
  description          = "Production Redis cluster with encryption"
  node_type            = "cache.r6g.large"
  num_cache_clusters   = 2
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  transit_encryption_enabled = true # PASS: TLS enforced — satisfies CALIPER-AWS-016
  at_rest_encryption_enabled = true

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  tags = {
    Environment = "production"
  }
}

# PASS: Redis cluster mode enabled with TLS
resource "aws_elasticache_replication_group" "pass_cluster_mode_tls" {
  replication_group_id       = "pass-redis-cluster"
  description                = "Clustered Redis with TLS"
  node_type                  = "cache.r6g.xlarge"
  num_node_groups            = 3
  replicas_per_node_group    = 1
  parameter_group_name       = "default.redis7.cluster.on"
  engine_version             = "7.0"
  port                       = 6379
  transit_encryption_enabled = true # PASS: TLS required even in cluster mode

  tags = {
    Environment = "production"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: transit encryption explicitly disabled — plaintext Redis traffic on the VPC
resource "aws_elasticache_replication_group" "fail_tls_disabled" {
  replication_group_id = "fail-redis-staging"
  description          = "Staging Redis without TLS"
  node_type            = "cache.t3.medium"
  num_cache_clusters   = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  transit_encryption_enabled = false # FAIL: plaintext traffic — fails CALIPER-AWS-016

  tags = {
    Environment = "staging"
  }
}

# FAIL: transit_encryption_enabled omitted — AWS default is false
resource "aws_elasticache_replication_group" "fail_tls_omitted" {
  replication_group_id = "fail-redis-dev"
  description          = "Dev Redis no TLS config"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  # transit_encryption_enabled omitted — defaults to false, plaintext Redis
  # fails CALIPER-AWS-016

  tags = {
    Environment = "development"
  }
}
