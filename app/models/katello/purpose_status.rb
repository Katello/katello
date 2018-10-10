module Katello
  class PurposeStatus < HostStatus::Status
    VALID = 0
    INVALID = 1
    UNKNOWN = 2

    SUBSTATUSES = [
      Katello::PurposeSlaStatus,
      Katello::PurposeRoleStatus,
      Katello::PurposeUsageStatus,
      Katello::PurposeAddonsStatus
    ].freeze

    def self.status_name
      N_('System Purpose')
    end

    def self.humanized_name
      'purpose'
    end

    def to_label(_options = {})
      case status
      when VALID
        N_('Matched')
      when INVALID
        N_('Mismatched')
      else
        N_('Unknown')
      end
    end

    def to_global(_options = {})
      case status
      when VALID
        ::HostStatus::Global::OK
      else
        ::HostStatus::Global::WARN
      end
    end

    def to_status(_options = {})
      return UNKNOWN unless relevant?

      SUBSTATUSES.each do |status_class|
        return INVALID if host.get_status(status_class).status != status_class::VALID
      end

      VALID
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end
  end
end
