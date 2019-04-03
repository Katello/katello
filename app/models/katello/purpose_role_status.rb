module Katello
  class PurposeRoleStatus < HostStatus::Status
    def self.status_name
      N_('Role')
    end

    def self.humanized_name
      'purpose_role'
    end

    def to_label(_options = {})
      Katello::PurposeStatus.to_label(status)
    end

    def to_status(options = {})
      Katello::PurposeStatus.to_status(self, :role_status, options)
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end

    def substatus?(_options = {})
      true
    end
  end
end
