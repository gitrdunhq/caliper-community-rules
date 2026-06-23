# Test fixtures for KIRBY-INF-027 / CALIPER-AWS-015 — Lambda Dead Letter Queue
# PASS: aws_lambda_function with a dead_letter_config block present
# FAIL: aws_lambda_function with no dead_letter_config block

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: Lambda function with DLQ pointing to an SQS queue
resource "aws_lambda_function" "pass_dlq_sqs" {
  function_name = "pass-order-processor"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "function.zip"

  dead_letter_config { # PASS: DLQ configured — failed async invocations are captured
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  tags = {
    Environment = "production"
  }
}

# PASS: Lambda function with DLQ pointing to an SNS topic (for fan-out alerting)
resource "aws_lambda_function" "pass_dlq_sns" {
  function_name = "pass-event-consumer"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main.handler"
  runtime       = "python3.12"
  filename      = "function.zip"

  dead_letter_config { # PASS: DLQ via SNS — satisfies CALIPER-AWS-015
    target_arn = aws_sns_topic.lambda_failures.arn
  }

  environment {
    variables = {
      ENV = "production"
    }
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: Lambda function with no dead_letter_config — failed async invocations are silently dropped
resource "aws_lambda_function" "fail_no_dlq" {
  function_name = "fail-data-ingester"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "ingest.handler"
  runtime       = "python3.12"
  filename      = "function.zip"

  # dead_letter_config omitted — async failures are lost with no audit trail
  # violates CALIPER-AWS-015

  tags = {
    Environment = "production"
  }
}

# FAIL: Lambda with reserved concurrency but still no DLQ
resource "aws_lambda_function" "fail_no_dlq_with_concurrency" {
  function_name                  = "fail-report-generator"
  role                           = aws_iam_role.lambda_exec.arn
  handler                        = "report.generate"
  runtime                        = "java21"
  filename                       = "function.jar"
  reserved_concurrent_executions = 10

  # dead_letter_config omitted — reserved concurrency does not substitute for a DLQ
  # fails CALIPER-AWS-015

  tags = {
    Environment = "staging"
  }
}
