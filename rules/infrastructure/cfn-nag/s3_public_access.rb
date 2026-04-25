# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class S3PublicAccessRule < BaseRule
  def rule_text
    'S3 bucket should have PublicAccessBlockConfiguration to prevent public access'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F002'
  end

  def audit_impl(cfn_model)
    violating_buckets = cfn_model.resources_by_type('AWS::S3::Bucket').reject do |bucket|
      bucket.publicAccessBlockConfiguration
    end

    violating_buckets.map(&:logical_resource_id)
  end
end
