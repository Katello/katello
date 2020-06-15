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
      Katello::TraceStatus].freeze
  end
end
