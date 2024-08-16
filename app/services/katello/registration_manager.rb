module Katello
  class RegistrationManager
    class << self
      private :new
      delegate :propose_existing_hostname, :new_host_from_facts, to: Katello::Host::SubscriptionFacet

      def determine_host_dmi_uuid(rhsm_params)
        host_uuid = rhsm_params.dig(:facts, 'dmi.system.uuid')

        if Katello::Host::SubscriptionFacet.override_dmi_uuid?(host_uuid)
          return [SecureRandom.uuid, true]
        end

        [host_uuid, false]
      end

      def process_registration(rhsm_params, content_view_environments, activation_keys = [])
        host_name = propose_existing_hostname(rhsm_params[:facts])
        host_uuid, host_uuid_overridden = determine_host_dmi_uuid(rhsm_params)

        rhsm_params[:facts]['dmi.system.uuid'] = host_uuid # ensure we find & validate against a potentially overridden UUID

        organization = validate_content_view_environment_org(content_view_environments, activation_keys.first)

        hosts = find_existing_hosts(host_name, host_uuid)

        validate_hosts(hosts, organization, host_name, host_uuid, host_uuid_overridden: host_uuid_overridden)

        host = hosts.first || new_host_from_facts(
          rhsm_params[:facts],
          organization,
          Location.default_host_subscribe_location!
        )
        host.organization = organization unless host.organization

        register_host(host, rhsm_params, content_view_environments, activation_keys)

        if host_uuid_overridden
          host.subscription_facet.update_dmi_uuid_override(host_uuid)
        end

        host
      end

      def dmi_uuid_allowed_dups
        Katello::Host::SubscriptionFacet::DMI_UUID_ALLOWED_DUPS
      end

      def dmi_uuid_change_allowed?(host, host_uuid_overridden)
        if host_uuid_overridden
          true
        elsif host.build && Setting[:host_profile_assume_build_can_change]
          true
        else
          Setting[:host_profile_assume]
        end
      end

      def find_existing_hosts(host_name, host_uuid)
        query = ::Host.unscoped.where("#{::Host.table_name}.name = ?", host_name)

        unless host_uuid.nil? || dmi_uuid_allowed_dups.include?(host_uuid) # no need to include the dmi uuid lookup
          query = query.left_outer_joins(:subscription_facet).or(::Host.unscoped.left_outer_joins(:subscription_facet)
            .where("#{Katello::Host::SubscriptionFacet.table_name}.dmi_uuid = ?", host_uuid)).distinct
        end

        query
      end

      def validate_content_view_environment_org(content_view_environments, activation_key)
        orgs = Set.new([activation_key&.organization])
        content_view_environments&.each do |cve|
          orgs << cve&.environment&.organization
        end
        orgs.delete(nil)
        if orgs.size != 1
          registration_error(_("Content view environments and activation key must all belong to the same organization"))
        end
        orgs.first
      end

      def validate_hosts(hosts, organization, host_name, host_uuid, host_uuid_overridden: false)
        return if hosts.empty?

        hosts = hosts.where(organization_id: [organization.id, nil])
        hosts_size = hosts.size

        if hosts_size == 0 # not in the correct org
          #TODO: http://projects.theforeman.org/issues/11532
          registration_error("Host with name %{host_name} is currently registered to a different org, please migrate host to %{org_name}.",
                             org_name: organization.name, host_name: host_name)
        end

        if hosts_size == 1
          host = hosts.first

          if host.name == host_name
            if !host.build && Setting[:host_re_register_build_only]
              registration_error("Host with name %{host_name} is currently registered but not in build mode (host_re_register_build_only==True). Unregister the host manually or put it into build mode to continue.", host_name: host_name)
            end

            current_dmi_uuid = host.subscription_facet&.dmi_uuid
            dmi_uuid_changed = current_dmi_uuid && current_dmi_uuid != host_uuid
            if dmi_uuid_changed && !dmi_uuid_change_allowed?(host, host_uuid_overridden)
              registration_error("This host is reporting a DMI UUID that differs from the existing registration.")
            end

            return true
          end
        end

        hosts = hosts.where.not(name: host_name)
        registration_error("The DMI UUID of this host (%{uuid}) matches other registered hosts: %{existing}", uuid: host_uuid, existing: joined_hostnames(hosts))
      end

      def registration_error(message, meta = {})
        fail(Katello::Errors::RegistrationError, _(message) % meta)
      end

      def joined_hostnames(hosts)
        hosts.pluck(:name).sort.join(', ')
      end

      # options:
      #  * organization_destroy: destroy some data associated with host, but
      #    leave items alone that will be removed later as part of org destroy
      #  * unregistering: unregister the host but don't destroy it
      #  * keep_kickstart_repository: ensure the KS repo ID is not set to nil
      def unregister_host(host, options = {})
        organization_destroy = options.fetch(:organization_destroy, false)
        unregistering = options.fetch(:unregistering, false)
        keep_kickstart_repository = options.fetch(:keep_kickstart_repository, false)

        # if the first operation fails, just raise the error since there's nothing to clean up yet.
        candlepin_consumer_destroy(host.subscription_facet.uuid) if !organization_destroy && host.subscription_facet.try(:uuid)

        # if this fails, there is not much to do about it right now. We can't really re-create the candlepin consumer.
        # This can be cleaned up later via clean_backend_objects.

        host.subscription_facet.try(:destroy!)

        if unregistering
          if keep_kickstart_repository
            remove_host_artifacts(host, kickstart_repository_id: host&.content_facet&.kickstart_repository_id)
          else
            remove_host_artifacts(host)
          end
        elsif organization_destroy
          host.content_facet.try(:destroy!)
          remove_host_artifacts(host, clear_content_facet: false)
        else
          host.content_facet.try(:destroy!)
          destroy_host_record(host.id)
        end
      end

      def register_host(host, consumer_params, content_view_environments, activation_keys = [])
        new_host = host.new_record?
        unless new_host
          host.save!
          # Keep the kickstart repository ID so the host's Medium isn't unset
          # Important for registering a host during provisioning
          unregister_host(host, :unregistering => true, :keep_kickstart_repository => true)
          host.reload
        end

        if activation_keys.present?
          if content_view_environments.blank?
            content_view_environments = [lookup_content_view_environment(activation_keys)]
          end
          set_host_collections(host, activation_keys)
        end
        fail _('Content view and environment not set for registration.') if content_view_environments.blank?

        host.save! #the host is in foreman db at this point

        host_uuid = get_uuid(consumer_params)
        consumer_params[:uuid] = host_uuid
        host.content_facet = populate_content_facet(host, content_view_environments, host_uuid)
        host.content_facet.cves_changed = false # prevent backend_update_needed from triggering an update on a nonexistent consumer
        host.subscription_facet = populate_subscription_facet(host, activation_keys, consumer_params, host_uuid)
        host.save! # the host has content and subscription facets at this point

        User.as_anonymous_admin do
          begin
            create_in_candlepin(host, content_view_environments, consumer_params, activation_keys)
          rescue StandardError => e
            # we can't call CP here since something bad already happened. Just clean up our DB as best as we can.
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
        ping_results[:services][:candlepin][:status] == "ok"
      end

      private

      def destroy_host_record(host_id)
        host = ::Host.find(host_id)
        host.destroy
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn("Attempted to destroy host %s but host is already gone." % host_id)
      end

      def get_uuid(params)
        if params.key?(:uuid)
          Rails.logger.info "assigning existing uuid #{params[:uuid]}"
        else
          Rails.logger.info "generating new uuid"
        end
        params.key?(:uuid) ? params[:uuid] : SecureRandom.uuid
      end

      def remove_partially_registered_new_host(host)
        host.content_facet.try(:destroy!)
        destroy_host_record(host.id)
      end

      def create_in_candlepin(host, content_view_environments, consumer_params, activation_keys)
        # if CP fails, nothing to clean up yet w.r.t. backend services
        cp_create = ::Katello::Resources::Candlepin::Consumer.create(content_view_environments.map(&:cp_id), consumer_params, activation_keys.map(&:cp_name), host.organization)
        ::Katello::Host::SubscriptionFacet.update_facts(host, consumer_params[:facts]) unless consumer_params[:facts].blank?
        uuid = cp_create[:uuid]
        if uuid.present? && uuid != host.subscription_facet.uuid
          Rails.logger.info(_("Candlepin returned different consumer uuid than requested (%s), updating uuid in subscription_facet.") % uuid)
          host.subscription_facet.uuid = uuid
          host.subscription_facet.save!
        end
        uuid
      end

      def finalize_registration(host)
        host = ::Host.find(host.id)
        host.subscription_facet.update_from_consumer_attributes(host.subscription_facet.candlepin_consumer.
            consumer_attributes.except(:guestIds, :facts))
        host.subscription_facet.save!
        host.refresh_statuses([
                                ::Katello::ErrataStatus,
                                ::Katello::RhelLifecycleStatus,
                              ])
      end

      def set_host_collections(host, activation_keys)
        host_collection_ids = activation_keys.flat_map(&:host_collection_ids).compact.uniq

        host_collection_ids.each do |host_collection_id|
          host_collection = ::Katello::HostCollection.find(host_collection_id)
          if !host_collection.unlimited_hosts && host_collection.max_hosts >= 0 &&
             host_collection.hosts.length >= host_collection.max_hosts
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
      rescue RestClient::ResourceNotFound
        Rails.logger.warn(_("Attempted to destroy consumer %s from candlepin, but consumer does not exist in candlepin") % host_uuid)
      rescue RestClient::Gone
        Rails.logger.warn(_("Candlepin consumer %s has already been removed") % host_uuid)
      end

      def populate_content_facet(host, content_view_environments, uuid)
        content_facet = host.content_facet || ::Katello::Host::ContentFacet.new(:host => host)
        content_facet.content_view_environments = content_view_environments
        content_facet.uuid = uuid
        content_facet.save!
        content_facet
      end

      def populate_subscription_facet(host, activation_keys, consumer_params, uuid)
        subscription_facet = host.subscription_facet || ::Katello::Host::SubscriptionFacet.new(:host => host)
        subscription_facet.last_checkin = Time.now
        subscription_facet.update_from_consumer_attributes(consumer_params.except(:guestIds))
        subscription_facet.uuid = uuid
        subscription_facet.user = User.current unless User.current.nil? || User.current.hidden?
        subscription_facet.save!
        subscription_facet.activation_keys = activation_keys
        subscription_facet
      end

      def remove_host_artifacts(host, clear_content_facet: true, kickstart_repository_id: nil)
        Rails.logger.debug "Host ID: #{host.id}, clear_content_facet: #{clear_content_facet}, kickstart_repository_id: #{kickstart_repository_id}"
        if host.content_facet && clear_content_facet
          host.content_facet.bound_repositories = []
          host.content_facet.applicable_errata = []
          host.content_facet.uuid = nil
          host.content_facet.content_view_environments = []
          host.content_facet.content_source = ::SmartProxy.pulp_primary
          host.content_facet.kickstart_repository_id = kickstart_repository_id
          host.content_facet.save!
          Rails.logger.debug "remove_host_artifacts: marking CVEs unchanged to prevent backend update"
          host.content_facet.mark_cves_unchanged
          host.content_facet.calculate_and_import_applicability
        end

        host.get_status(::Katello::ErrataStatus).destroy
        host.get_status(::Katello::TraceStatus).destroy
        host.installed_packages.delete_all

        host.rhsm_fact_values.delete_all
      end
    end
  end
end
