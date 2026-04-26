# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class S3PublicAccessRule < BaseRule
  COMPLIANCE = {
    kirby_id: 'KIRBY-INF-005',
    property_domain: 'confidentiality',
    compliance_mappings: [
      { framework: 'nist-800-53-r5', controls: ['AC-3', 'AC-6'] },
      { framework: 'cis-aws-v2.0', controls: ['2.1.2', '2.1.4'] },
      { framework: 'soc2-tsc', controls: ['CC6.1', 'CC6.6'] },
      { framework: 'pci-dss-v4.0', controls: ['1.2.1'] },
      { framework: 'iso-27001-2022', controls: ['A.8.3'] },
      { framework: 'aws-config', controls: ['S3_BUCKET_PUBLIC_READ_PROHIBITED', 'S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS'] }
    ]
  }.freeze

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
