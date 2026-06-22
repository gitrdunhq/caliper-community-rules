# Test fixtures for KIRBY-INF-009 / CALIPER-AWS-007 — Security Group SSH Lockdown
# PASS: security group rules with restricted CIDRs (no 0.0.0.0/0 or ::/0)
# FAIL: security group rules allowing unrestricted IPv4 (0.0.0.0/0) or IPv6 (::/0) ingress
#
# TFSEC LIMITATION: CALIPER-AWS-007 applies to all aws_security_group_rule resources,
# not only port 22. Intentionally public ports (80, 443) should carry:
#   # tfsec-ignore:CALIPER-AWS-007
#   # tfsec-ignore:CALIPER-AWS-007-IPV6

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: SSH restricted to a specific management CIDR only
resource "aws_security_group_rule" "pass_ssh_restricted" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"] # PASS: restricted to private network

  security_group_id = "sg-00000000000000001"
}

# PASS: HTTPS open to the world — cidr not 0.0.0.0/0 here, restricted to org CIDR
resource "aws_security_group_rule" "pass_https_restricted" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["203.0.113.0/24"] # PASS: specific org IP range

  security_group_id = "sg-00000000000000001"
}

# PASS: SSH IPv6 restricted to org prefix only
resource "aws_security_group_rule" "pass_ssh_ipv6_restricted" {
  type             = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  ipv6_cidr_blocks = ["2001:db8::/32"] # PASS: specific IPv6 prefix

  security_group_id = "sg-00000000000000001"
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: SSH open to the entire internet (0.0.0.0/0) — primary target of CALIPER-AWS-007
resource "aws_security_group_rule" "fail_ssh_open_world" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # FAIL: unrestricted IPv4 — fails CALIPER-AWS-007

  security_group_id = "sg-00000000000000002"
}

# FAIL: SSH open to the entire internet over IPv6 — target of CALIPER-AWS-007-IPV6
resource "aws_security_group_rule" "fail_ssh_open_ipv6" {
  type             = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  ipv6_cidr_blocks = ["::/0"] # FAIL: unrestricted IPv6 — fails CALIPER-AWS-007-IPV6

  security_group_id = "sg-00000000000000002"
}

# FAIL: any port open to 0.0.0.0/0 — tfsec limitation causes this to be flagged too
# Add tfsec-ignore:CALIPER-AWS-007 if this is intentionally public
resource "aws_security_group_rule" "fail_http_open_world" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # FAIL: flagged by CALIPER-AWS-007 due to tfsec limitation
  # tfsec-ignore:CALIPER-AWS-007  # uncomment to suppress for intentionally public HTTP

  security_group_id = "sg-00000000000000002"
}
