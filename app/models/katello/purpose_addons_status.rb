module Katello
  class PurposeAddonsStatus < HostStatus::Status
    UNKNOWN = Katello::PurposeStatus::UNKNOWN
    def self.status_name
      N_('Addons')
    end

    def self.humanized_name
      'purpose_addons'
    end

    def to_label(_options = {})
      Katello::PurposeStatus.to_label(status)
    end

    def to_status(options = {})
      Katello::PurposeStatus.to_status(self, :addons_status, options)
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end

    def substatus?(_options = {})
      true
    end
  end
end
