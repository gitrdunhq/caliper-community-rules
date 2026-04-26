"""
Semgrep test fixtures for KIRBY-SEC-006 / no-root-access-keys
ruleid annotations mark lines that must trigger a finding.
ok annotations mark lines that must NOT trigger a finding.
"""

import os

import boto3

# -------------------------------------------------------------------------
# FAIL cases -- boto3.client with hardcoded AKIA root key
# -------------------------------------------------------------------------

# ruleid: no-root-access-keys
client = boto3.client(
    "iam",
    aws_access_key_id="AKIAIOSFODNN7EXAMPLE",
    aws_secret_access_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    region_name="us-east-1",
)

# ruleid: no-root-access-keys
s3 = boto3.client(
    "s3",
    aws_access_key_id="AKIAI44QH8DHBEXAMPLE",
    aws_secret_access_key="je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY",
)


# -------------------------------------------------------------------------
# FAIL cases -- boto3.Session with hardcoded AKIA root key
# -------------------------------------------------------------------------

# ruleid: no-root-access-keys
session = boto3.Session(
    aws_access_key_id="AKIAIOSFODNN7EXAMPLE",
    aws_secret_access_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    region_name="us-east-1",
)

# ruleid: no-root-access-keys
backup_session = boto3.Session(
    aws_access_key_id="AKIAI44QH8DHBEXAMPLE",
    aws_secret_access_key="je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY",
)


# -------------------------------------------------------------------------
# FAIL cases -- root user ARN passed to boto3 API call
# -------------------------------------------------------------------------

sts = boto3.client("sts", region_name="us-east-1")

# ruleid: no-root-access-keys
resp = sts.assume_role(
    RoleArn="arn:aws:iam::606824098034:root",
    RoleSessionName="root-session",
)

# ruleid: no-root-access-keys
sts.assume_role(RoleArn="arn:aws:iam::785375501972:root", RoleSessionName="bad")


# -------------------------------------------------------------------------
# PASS cases -- credentials from environment / config, not hardcoded
# -------------------------------------------------------------------------

# ok: no-root-access-keys -- no credentials supplied; boto3 uses default credential chain
client_ok = boto3.client("iam", region_name="us-east-1")

# ok: no-root-access-keys -- session without hardcoded keys; uses instance profile
session_ok = boto3.Session(region_name="us-east-1")

# ok: no-root-access-keys -- access key read from environment variable at runtime
access_key_env = os.environ["AWS_ACCESS_KEY_ID"]
client_env = boto3.client("iam", aws_access_key_id=access_key_env)

# ok: no-root-access-keys -- key loaded from secrets manager, not a literal
access_key_var = get_secret("aws/access-key-id")  # noqa: F821 (stub for test)
client_secret = boto3.client("iam", aws_access_key_id=access_key_var)

# ok: no-root-access-keys -- legitimate IAM role ARN (not root)
sts.assume_role(
    RoleArn="arn:aws:iam::606824098034:role/DeployRole",
    RoleSessionName="deploy",
)
