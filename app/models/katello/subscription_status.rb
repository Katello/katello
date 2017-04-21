module Katello
  class SubscriptionStatus < HostStatus::Status
    UNKNOWN = 3
    INVALID = 2
    PARTIAL = 1
    VALID = 0

    def self.status_name
      N_("Subscription")
    end

    def to_label(_options = {})
      case status
      when VALID
        N_("Fully entitled")
      when PARTIAL
        N_("Partially entitled")
      when INVALID
        N_("Unentitled")
      else
        N_("Unknown subscription status")
      end
    end

    def to_global(_options = {})
      case status
      when INVALID
        ::HostStatus::Global::ERROR
      when PARTIAL
        ::HostStatus::Global::WARN
      when VALID
        ::HostStatus::Global::OK
      when UNKNOWN
        ::HostStatus::Global::WARN
      end
    end

    def to_status(options = {})
      return UNKNOWN unless host.subscription_facet.try(:uuid)
      status_override = options.fetch(:status_override, nil)
      status = status_override || Katello::Candlepin::Consumer.new(host.subscription_facet.uuid, host.organization.label).entitlement_status

      case status
      when Katello::Candlepin::Consumer::ENTITLEMENTS_VALID
        VALID
      when Katello::Candlepin::Consumer::ENTITLEMENTS_PARTIAL
        PARTIAL
      when Katello::Candlepin::Consumer::ENTITLEMENTS_INVALID
        INVALID
      else
        UNKNOWN
      end
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end
  end
end
