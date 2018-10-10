module Katello
  class PurposeSlaStatus < HostStatus::Status
    VALID = 0
    INVALID = 1
    UNKNOWN = 2

    def self.status_name
      N_('Service Level')
    end

    def self.humanized_name
      'purpose_sla'
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

      return INVALID if options[:status_override] == false

      return VALID if options[:status_override] || consumer.compliant_sla?

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
