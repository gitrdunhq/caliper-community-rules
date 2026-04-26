# Test fixtures for KIRBY-SEC-006 / EEDOM-AWS-011 — No Root Access Keys
# PASS: aws_iam_access_key for a named IAM user (user != "root")
# FAIL: aws_iam_access_key with user = "root"

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

resource "aws_iam_user" "deploy" {
  name = "deploy-bot"
  path = "/service/"
}

# PASS: access key created for a named service account via resource reference
resource "aws_iam_access_key" "pass_service_account" {
  user = aws_iam_user.deploy.name
}

resource "aws_iam_user" "ci_runner" {
  name = "ci-runner"
}

# PASS: access key for another non-root IAM user (literal non-root username)
resource "aws_iam_access_key" "pass_ci_runner" {
  user = "ci-runner"
}

resource "aws_iam_user" "readonly_auditor" {
  name = "readonly-auditor"
  path = "/auditors/"
}

# PASS: access key for read-only auditor role — not root
resource "aws_iam_access_key" "pass_auditor" {
  user = aws_iam_user.readonly_auditor.name
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: access key explicitly referencing the root user — fails EEDOM-AWS-011
resource "aws_iam_access_key" "fail_root_key" {
  user = "root" # FAIL: root account access keys must never exist (CIS 1.4)
}
