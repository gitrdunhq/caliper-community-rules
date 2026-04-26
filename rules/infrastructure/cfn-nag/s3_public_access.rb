# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class S3PublicAccessRule < BaseRule
  def rule_text
    'S3 bucket should have PublicAccessBlockConfiguration with all four flags set to true'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F002'
  end

  REQUIRED_FLAGS = %w[
    blockPublicAcls
    blockPublicPolicy
    ignorePublicAcls
    restrictPublicBuckets
  ].freeze

  def audit_impl(cfn_model)
    violating_buckets = cfn_model.resources_by_type('AWS::S3::Bucket').reject do |bucket|
      config = bucket.publicAccessBlockConfiguration
      next false unless config

      REQUIRED_FLAGS.all? { |flag| config.send(flag) == true }
    end

    violating_buckets.map(&:logical_resource_id)
  end
end
