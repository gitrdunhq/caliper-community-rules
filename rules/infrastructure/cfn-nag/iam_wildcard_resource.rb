# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class IamWildcardResourceRule < BaseRule
  def rule_text
    'IAM policy should not allow * resource — scope to specific ARNs'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F001'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::Policy').select do |policy|
      policy.policyDocument.Statement.any? do |statement|
        resources = [statement.Resource].flatten
        resources.any? { |r| r == '*' }
      end
    end

    violating_policies.map(&:logical_resource_id)
  end
end
