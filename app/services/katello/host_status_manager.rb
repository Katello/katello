module Katello
  class HostStatusManager
    STATUSES = [
      Katello::ErrataStatus,
      Katello::RhelLifecycleStatus,
      Katello::TraceStatus].freeze
  end
end
