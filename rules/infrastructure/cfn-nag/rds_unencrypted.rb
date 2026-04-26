# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class RdsUnencryptedRule < BaseRule
  def rule_text
    'RDS instance should have StorageEncrypted enabled (instances restored from ' \\
    'encrypted snapshots, read replicas of encrypted primaries, and Aurora cluster ' \\
    'members inherit encryption and are exempt)'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'GITRDUN_F003'
  end

  def audit_impl(cfn_model)
    violating_instances = cfn_model.resources_by_type('AWS::RDS::DBInstance').reject do |instance|
      encrypted_explicitly?(instance) || inherits_encryption?(instance)
    end

    violating_instances.map(&:logical_resource_id)
  end

  private

  def encrypted_explicitly?(instance)
    instance.storageEncrypted == true
  end

  def inherits_encryption?(instance)
    # Restored from snapshot â encryption inherited from the snapshot
    return true if instance.respond_to?(:dBSnapshotIdentifier) && instance.dBSnapshotIdentifier

    # Read replica â encryption inherited from the source instance
    return true if instance.respond_to?(:sourceDBInstanceIdentifier) && instance.sourceDBInstanceIdentifier

    # Aurora cluster member â encryption is set at the DBCluster level
    return true if instance.respond_to?(:engine) && aurora_engine?(instance.engine) &&
                   instance.respond_to?(:dBClusterIdentifier) && instance.dBClusterIdentifier

    false
  end

  def aurora_engine?(engine)
    return false unless engine.is_a?(String)

    engine.start_with?('aurora')
  end
end
