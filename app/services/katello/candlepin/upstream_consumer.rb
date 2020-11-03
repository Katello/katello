module Katello
  module Candlepin
    class UpstreamConsumer
      def initialize(organization)
        @organization = organization
      end

      def simple_content_access_eligible?
        eligible = true
        ::Organization.as_org(@organization) do
          content_modes = resource_class.content_access

          if content_modes.key?(:contentAccessModeList)
            eligible = content_modes[:contentAccessModeList].include?('org_environment')
          end
        end

        eligible
      end

      private

      def resource_class
        Katello::Resources::Candlepin::UpstreamConsumer
      end
    end
  end
end
