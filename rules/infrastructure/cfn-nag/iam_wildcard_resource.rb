# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class IamWildcardResourceRule < BaseRule
  def rule_text
    'IAM policy should not allow * resource â scope to specific ARNs'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F001'
  end

  # Resource types with a top-level PolicyDocument property
  STANDALONE_POLICY_TYPES = %w[
    AWS::IAM::Policy
    AWS::IAM::ManagedPolicy
  ].freeze

  # Resource types that embed inline policies via a Policies array property
  INLINE_POLICY_TYPES = %w[
    AWS::IAM::Role
    AWS::IAM::Group
    AWS::IAM::User
  ].freeze

  def audit_impl(cfn_model)
    violating_ids = []

    STANDALONE_POLICY_TYPES.each do |type|
      cfn_model.resources_by_type(type).each do |policy|
        if policy_document_has_wildcard?(policy.policyDocument)
          violating_ids << policy.logical_resource_id
        end
      end
    end

    INLINE_POLICY_TYPES.each do |type|
      cfn_model.resources_by_type(type).each do |resource|
        next unless resource.respond_to?(:policies) && resource.policies

        resource.policies.each do |inline_policy|
          if policy_document_has_wildcard?(inline_policy.policyDocument)
            violating_ids << resource.logical_resource_id
            break
          end
        end
      end
    end

    violating_ids
  end

  private

  def policy_document_has_wildcard?(policy_document)
    return false unless policy_document&.Statement

    policy_document.Statement.any? do |statement|
      resources = [statement.Resource].flatten
      resources.any? { |r| r == '*' }
    end
  end
end
