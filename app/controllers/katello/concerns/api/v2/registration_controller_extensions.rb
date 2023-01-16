module Katello
  module Concerns
    module Api::V2::RegistrationControllerExtensions
      extend ActiveSupport::Concern

      def prepare_host
        if params['uuid']
          @host = Katello::Host::SubscriptionFacet.find_by(uuid: params['uuid'])&.host
          if @host.nil?
            msg = _("Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this instance") % params['uuid']
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
          new_lce = KTEnvironment.readable.find(params['host']['lifecycle_environment_id'])
          @host.content_facet.lifecycle_environment = new_lce
          @host.update_candlepin_associations
        end

        super
      end

      def context_urls
        super.merge(rhsm_url: smart_proxy.rhsm_url, pulp_content_url: smart_proxy.pulp_content_url)
      end

      private

      def smart_proxy
        @smart_proxy ||= begin
          proxy = params[:url] ? find_smart_proxy : SmartProxy.pulp_primary

          fail Foreman::Exception, _('Smart proxy content source not found!') unless proxy
          fail Foreman::Exception, _('Pulp 3 is not enabled on Smart proxy!') unless proxy.pulp3_enabled?

          proxy
        end
      end

      def find_smart_proxy
        auth_smart_proxy
        @detected_proxy
      end
    end
  end
end
