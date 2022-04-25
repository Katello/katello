module Katello
  class PurposeSlaStatus < HostStatus::Status
    UNKNOWN = Katello::PurposeStatus::UNKNOWN
    def self.status_name
      N_('Service level')
    end

    def self.humanized_name
      'purpose_sla'
    end

    def to_label(_options = {})
      Katello::PurposeStatus.to_label(status)
    end

    def to_status(options = {})
      Katello::PurposeStatus.to_status(self, :sla_status, options)
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end

    def substatus?(_options = {})
      true
    end
  end
end
