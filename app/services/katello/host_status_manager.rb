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

    PURPOSE_STATUS = [
      Katello::PurposeStatus,
      Katello::PurposeAddonsStatus,
      Katello::PurposeRoleStatus,
      Katello::PurposeSlaStatus,
      Katello::PurposeUsageStatus].freeze
  end
end
