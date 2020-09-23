module Katello
  module Concerns
    module Api::V2::RegistrationControllerExtensions
      extend ActiveSupport::Concern

      def prepare_host
        if params['uuid']
          @host = Katello::Host::SubscriptionFacet.find_by(uuid: params['uuid']).host
          @host.assign_attributes(host_params('host'))
          @host.save!
        else
          super
        end
      end
    end
  end
end
