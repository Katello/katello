module Katello
  module Concerns
    module Api::V2::RegistrationControllerExtensions
      extend ActiveSupport::Concern

      def prepare_host
        if params['uuid']
          @host = Katello::Host::SubscriptionFacet.find_by(uuid: params['uuid'])&.host
          if @host.nil?
            msg = N_("Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this Foreman") % params['uuid']
            fail ActiveRecord::RecordNotFound, msg
          end
          @host.assign_attributes(host_params('host'))
          @host.save!
        else
          super
        end
      end

      def host_setup_extension
        if params['host']['lifecycle_environment_id']
          @host.update!(lifecycle_environment: KTEnvironment.readable.find(params['host']['lifecycle_environment_id']))
        end

        super
      end
    end
  end
end
