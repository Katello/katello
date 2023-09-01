module Katello
  class HostStatusManager
    STATUSES = [
      Katello::ErrataStatus,
      Katello::SubscriptionStatus,
      Katello::PurposeSlaStatus,
      Katello::PurposeRoleStatus,
      Katello::PurposeUsageStatus,
      Katello::PurposeAddonsStatus,
      Katello::PurposeStatus,
      Katello::RhelLifecycleStatus,
      Katello::TraceStatus].freeze

    PURPOSE_STATUS = [
      Katello::PurposeStatus,
      Katello::PurposeAddonsStatus,
      Katello::PurposeRoleStatus,
      Katello::PurposeSlaStatus,
      Katello::PurposeUsageStatus].freeze

    def self.update_subscription_status_to_sca(hosts)
      HostStatus::Status.where(host: hosts, type: Katello::SubscriptionStatus.to_s).update(status: Katello::SubscriptionStatus::DISABLED)
    end

    def self.clear_syspurpose_status(hosts)
      host_purpose = HostStatus::Status.where(type: ::Katello::HostStatusManager::PURPOSE_STATUS.map(&:to_s)).where('host_id in (?)', hosts.pluck(:id))
      host_purpose.destroy_all
    end
  end
end
