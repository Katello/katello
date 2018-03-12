module Katello
  class RegistrationManager
    class << self
      private :new

      # options:
      #  * organization_destroy: destroy some data associated with host, but
      #    leave items alone that will be removed later as part of org destroy
      #  * unregistering: unregister the host but don't destroy it
      def unregister_host(host, options = {})
        organization_destroy = options.fetch(:organization_destroy, false)
        unregistering = options.fetch(:unregistering, false)

        # if the first operation fails, just raise the error since there's nothing to clean up yet.
        candlepin_consumer_destroy(host.subscription_facet.uuid) if !organization_destroy && host.subscription_facet.try(:uuid)

        # if this fails, there is not much to do about it right now. We can't really re-create the candlepin consumer.
        # This can be cleaned up later via clean_backend_objects.
        pulp_consumer_destory(host.content_facet.uuid) if host.content_facet.try(:uuid)

        host.subscription_facet.try(:destroy!)

        if unregistering
          remove_host_artifacts(host)
        elsif organization_destroy
          host.content_facet.try(:destroy!)
          remove_host_artifacts(host, false)
        else
          host.content_facet.try(:destroy!)
          destroy_host_record(host.id)
        end
      end

      def register_host(host, consumer_params, content_view_environment, activation_keys = [])
        new_host = host.new_record?

        unless new_host
          host.save!
          unregister_host(host, :unregistering => true)
          host.reload
        end

        unless activation_keys.empty?
          content_view_environment ||= lookup_content_view_environment(activation_keys)
          set_host_collections(host, activation_keys)
        end
        fail _('Content View and Environment not set for registration.') if content_view_environment.nil?

        host.save! #the host is in foreman db at this point

        host_uuid = get_uuid(consumer_params)
        consumer_params[:uuid] = host_uuid
        host.content_facet = populate_content_facet(host, content_view_environment, host_uuid)
        host.subscription_facet = populate_subscription_facet(host, activation_keys, consumer_params, host_uuid)
        host.save! # the host has content and subscription facets at this point
        create_initial_subscription_status(host)

        User.as_anonymous_admin do
          begin
            create_in_cp_and_pulp(host, content_view_environment, consumer_params, activation_keys)
          rescue StandardError => e
            # we can't call CP or pulp here since something bad already happened. Just clean up our DB as best as we can.
            host.subscription_facet.try(:destroy!)
            new_host ? remove_partially_registered_new_host(host) : remove_host_artifacts(host)
            raise e
          end

          finalize_registration(host)
        end
      end

      def check_registration_services
        ping_results = {}
        User.as_anonymous_admin do
          ping_results = Katello::Ping.ping
        end
        ping_results[:services][:pulp][:status] == "ok" && ping_results[:services][:candlepin][:status] == "ok"
      end

      private

      def destroy_host_record(host_id)
        host = ::Host.find(host_id)
        host.destroy
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn("Attempted to destroy host %s but host is already gone." % host_id)
      end

      def get_uuid(params)
        params.key?(:uuid) ? params[:uuid] : SecureRandom.uuid
      end

      def remove_partially_registered_new_host(host)
        host.content_facet.try(:destroy!)
        destroy_host_record(host.id)
      end

      def create_initial_subscription_status(host)
        ::Katello::SubscriptionStatus.create!(:host => host, :status => ::Katello::SubscriptionStatus::UNKNOWN)
      end

      def create_in_cp_and_pulp(host, content_view_environment, consumer_params, activation_keys)
        # if CP fails, nothing to clean up yet w.r.t. backend services
        cp_create = ::Katello::Resources::Candlepin::Consumer.create(content_view_environment.cp_id, consumer_params, activation_keys.map(&:cp_name))
        ::Katello::Host::SubscriptionFacet.update_facts(host, consumer_params[:facts]) unless consumer_params[:facts].blank?

        # if pulp fails, remove the CP consumer we just made
        begin
          ::Katello.pulp_server.extensions.consumer.create(cp_create[:uuid], display_name: host.name)
        rescue StandardError => e
          ::Katello::Resources::Candlepin::Consumer.destroy(cp_create[:uuid])
          raise e
        end
        cp_create[:uuid]
      end

      def finalize_registration(host)
        host = ::Host.find(host.id)
        host.subscription_facet.update_from_consumer_attributes(host.subscription_facet.candlepin_consumer.
            consumer_attributes.except(:guestIds, :facts))
        host.subscription_facet.save!
        host.subscription_facet.update_subscription_status
        host.content_facet.update_errata_status
        host.refresh_global_status!
      end

      def set_host_collections(host, activation_keys)
        host_collection_ids = activation_keys.flat_map(&:host_collection_ids).compact.uniq

        host_collection_ids.each do |host_collection_id|
          host_collection = ::Katello::HostCollection.find(host_collection_id)
          if !host_collection.unlimited_hosts && host_collection.max_hosts >= 0 &&
             host_collection.systems.length >= host_collection.max_hosts
            fail _("Host collection '%{name}' exceeds maximum usage limit of '%{limit}'") %
                     {:limit => host_collection.max_hosts, :name => host_collection.name}
          end
        end
        host.host_collection_ids = host_collection_ids
      end

      def lookup_content_view_environment(activation_keys)
        activation_key = activation_keys.reverse.detect do |act_key|
          act_key.environment && act_key.content_view
        end
        if activation_key
          ::Katello::ContentViewEnvironment.where(:content_view_id => activation_key.content_view, :environment_id => activation_key.environment).first
        else
          fail _('At least one activation key must have a lifecycle environment and content view assigned to it')
        end
      end

      def candlepin_consumer_destroy(host_uuid)
        ::Katello::Resources::Candlepin::Consumer.destroy(host_uuid)
      rescue RestClient::Gone
        Rails.logger.error(_("Consumer %s has already been removed") % host_uuid)
      end

      def pulp_consumer_destory(host_uuid)
        ::Katello.pulp_server.extensions.consumer.delete(host_uuid)
      rescue RestClient::ResourceNotFound
        Rails.logger.error(_("Pulp Consumer %s has already been removed") % host_uuid)
      end

      def populate_content_facet(host, content_view_environment, uuid)
        content_facet = host.content_facet || ::Katello::Host::ContentFacet.new(:host => host)
        content_facet.content_view = content_view_environment.content_view
        content_facet.lifecycle_environment = content_view_environment.environment
        content_facet.uuid = uuid
        content_facet.save!
        content_facet
      end

      def populate_subscription_facet(host, activation_keys, consumer_params, uuid)
        subscription_facet = host.subscription_facet || ::Katello::Host::SubscriptionFacet.new(:host => host)
        subscription_facet.last_checkin = Time.now
        subscription_facet.update_from_consumer_attributes(consumer_params.except(:guestIds, :facts))
        subscription_facet.uuid = uuid
        subscription_facet.user = User.current unless User.current.nil? || User.current.hidden?
        subscription_facet.save!
        subscription_facet.activation_keys = activation_keys
        subscription_facet
      end

      def remove_host_artifacts(host, clear_content_facet = true)
        if host.content_facet && clear_content_facet
          host.content_facet.bound_repositories = []
          host.content_facet.applicable_errata = []
          host.content_facet.uuid = nil
          host.content_facet.save!
        end

        host.get_status(::Katello::ErrataStatus).destroy
        host.get_status(::Katello::SubscriptionStatus).destroy
        host.get_status(::Katello::TraceStatus).destroy
        host.installed_packages.delete_all
      end
    end
  end
end
