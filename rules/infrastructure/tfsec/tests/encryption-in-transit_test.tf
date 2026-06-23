# Test fixtures for KIRBY-SEC-007 / CALIPER-AWS-012 — Encryption in Transit
# PASS: aws_lb_listener / aws_alb_listener using HTTPS or TLS protocol
# FAIL: aws_lb_listener / aws_alb_listener using HTTP protocol
#
# TFSEC LIMITATION: CALIPER-AWS-012 flags any listener whose protocol attribute
# is not HTTPS or TLS. HTTP listeners used exclusively as HTTP-to-HTTPS
# redirects are architecturally acceptable but will still trigger this check
# because tfsec evaluates protocol at the attribute level, not by examining
# the action block. Suppress redirect-only listeners with:
#   # tfsec-ignore:CALIPER-AWS-012

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: HTTPS ALB listener with an ssl_policy — terminates TLS at the load balancer
resource "aws_lb_listener" "pass_https_with_ssl_policy" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
  port              = 443
  protocol          = "HTTPS" # PASS: encrypted protocol — satisfies CALIPER-AWS-012

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/1234567890abcdef"
  }
}

# PASS: TLS NLB listener — required protocol for Network Load Balancers
resource "aws_lb_listener" "pass_tls_nlb" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/1234567890abcdef"
  port              = 443
  protocol          = "TLS" # PASS: TLS for NLB — satisfies CALIPER-AWS-012

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/aaaaaaaa-bbbb-cccc-dddd-ffffffffffffffff"

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-nlb-tg/1234567890abcdef"
  }
}

# PASS: aws_alb_listener alias — HTTPS satisfies check on alias resource type too
resource "aws_alb_listener" "pass_alb_alias_https" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb2/abcdef1234567890"
  port              = 8443
  protocol          = "HTTPS" # PASS: aws_alb_listener alias — satisfies CALIPER-AWS-012

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/bbbbbbbb-cccc-dddd-eeee-ffffffffffff00"

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg2/abcdef1234567890"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: plain HTTP listener — transmits data unencrypted — fails CALIPER-AWS-012
resource "aws_lb_listener" "fail_http_plain" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
  port              = 80
  protocol          = "HTTP" # FAIL: plaintext HTTP — fails CALIPER-AWS-012

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/1234567890abcdef"
  }
}

# FAIL: HTTP redirect-only listener — architecturally acceptable but flagged by CALIPER-AWS-012
# due to tfsec's attribute-level evaluation (see TFSEC LIMITATION note at top of file).
# Add tfsec-ignore:CALIPER-AWS-012 with a comment if this pattern is intentional.
resource "aws_lb_listener" "fail_http_redirect_no_suppress" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
  port              = 80
  protocol          = "HTTP" # FAIL: flagged by CALIPER-AWS-012 despite redirect intent — add tfsec-ignore to suppress

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# PASS (suppressed): HTTP redirect-only listener with explicit ignore annotation
# This is the correct pattern when an HTTP listener is intentionally redirect-only.
resource "aws_lb_listener" "pass_http_redirect_suppressed" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
  port              = 80
  # tfsec-ignore:CALIPER-AWS-012 — HTTP-to-HTTPS permanent redirect only; no data in transit
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# FAIL: aws_alb_listener alias with HTTP — alias resource type is also checked
resource "aws_alb_listener" "fail_alb_alias_http" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb2/abcdef1234567890"
  port              = 80
  protocol          = "HTTP" # FAIL: aws_alb_listener alias plaintext HTTP — fails CALIPER-AWS-012

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg2/abcdef1234567890"
  }
}
