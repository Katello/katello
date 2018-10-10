module Katello
  class PurposeAddonsStatus < HostStatus::Status
    VALID = 0
    INVALID = 1
    UNKNOWN = 2

    def self.status_name
      N_('Addons')
    end

    def self.humanized_name
      'purpose_addons'
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

    def to_status(options = {})
      return UNKNOWN unless relevant?

      status_override = options[:status_override]

      return INVALID if status_override == false

      return VALID if status_override || consumer.compliant_addons?

      INVALID
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end

    def substatus?(_options = {})
      true
    end

    def consumer
      Katello::Candlepin::Consumer.new(host.subscription_facet.uuid, host.organization.label)
    end
  end
end
