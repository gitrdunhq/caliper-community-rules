# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class RdsUnencryptedRule < BaseRule
  def rule_text
    'RDS instance should have StorageEncrypted enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F003'
  end

  def audit_impl(cfn_model)
    violating_instances = cfn_model.resources_by_type('AWS::RDS::DBInstance').reject do |instance|
      instance.storageEncrypted
    end

    violating_instances.map(&:logical_resource_id)
  end
end
