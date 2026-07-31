module Katello
  module Concerns
    module Api::V2::RegistrationControllerExtensions
      extend ActiveSupport::Concern

      def prepare_host
        if params['uuid']
          host_id = Katello::Host::SubscriptionFacet.find_by(uuid: params['uuid'])&.host_id
          @host = ::Host::Managed.unscoped.find_by(id: host_id)
          if @host.nil?
            msg = _("Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this instance") % params['uuid']
            fail ActiveRecord::RecordNotFound, msg
          end
          @host.assign_attributes(host_params('host'))
          @host.owner = User.current
          @host.save!
        else
          super
        end
      end

      def context_urls
        super.merge(rhsm_url: pulpcore_proxy.rhsm_url, pulp_content_url: pulpcore_proxy.pulp_content_url)
      end

      def default_location
        Location.authorized(:view_locations).find_by(title: Setting[:default_location_subscribed_hosts]) || super
      end

      private

      def pulpcore_proxy
        @pulpcore_proxy ||= begin
          proxy = params[:url] ? find_smart_proxy : SmartProxy.pulp_primary

          fail Foreman::Exception, _('Smart proxy content source not found!') unless proxy

          unless proxy.pulp3_enabled?
            proxy = proxy.self_or_colocated_with_feature(SmartProxy::PULP3_FEATURE)
          end

          fail Foreman::Exception, _('Pulp 3 is not enabled on Smart proxy!') unless proxy&.pulp3_enabled?

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
