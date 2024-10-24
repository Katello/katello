module Katello
  # this is Katello's host bulk actions controller, not to be confused with Foreman's
  class Api::V2::HostsBulkActionsController < Api::V2::ApiController
    include ::Api::V2::BulkHostsExtension
    include Katello::Concerns::Api::V2::ContentOverridesController
    include Katello::ContentSourceHelper
    include ::Foreman::Renderer::Scope::Macros::Base

    before_action :find_host_collections, only: [:bulk_add_host_collections, :bulk_remove_host_collections]
    before_action :find_environment, only: [:environment_content_view]
    before_action :find_content_view, only: [:environment_content_view]
    before_action :find_editable_hosts, except: [:destroy_hosts, :resolve_traces, :change_content_source]
    before_action :find_deletable_hosts, only: [:destroy_hosts]
    before_action :find_readable_hosts, only: [:applicable_errata, :installable_errata, :available_incremental_updates]
    before_action :find_errata, only: [:available_incremental_updates]
    before_action :find_organization, only: [:add_subscriptions]
    before_action :find_traces, only: [:resolve_traces]

    before_action :validate_organization, only: [:add_subscriptions]

    # disable *_count fields on erratum rabl, since they perform N+1 queries
    before_action :disable_erratum_hosts_count

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def_param_group :bulk_params do
      param :organization_id, :number, :required => true, :desc => N_("ID of the organization")
      param :included, Hash, :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for hosts to perform an action on")
        param :ids, Array, :required => false, :desc => N_("List of host ids to perform an action on")
      end
      param :excluded, Hash, :required => true, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of host ids to exclude and not run an action on")
      end
    end

    api :PUT, "/hosts/bulk/add_host_collections",
        N_("Add one or more host collections to one or more hosts")
    param_group :bulk_params
    param :host_collection_ids, Array, :desc => N_("List of host collection ids"), :required => true
    def bulk_add_host_collections
      unless params[:host_collection_ids].blank?
        display_messages = []

        @host_collections.each do |host_collection|
          pre_host_collection_count = host_collection.host_ids.count
          host_collection.host_ids =  (host_collection.host_ids + @hosts.map(&:id)).uniq
          host_collection.save!

          final_count = host_collection.host_ids.count - pre_host_collection_count
          display_messages << _("Successfully added %{count} content host(s) to host collection %{host_collection}.") %
              {:count => final_count, :host_collection => host_collection.name }
        end
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => display_messages }
    end

    api :PUT, "/hosts/bulk/remove_host_collections",
        N_("Remove one or more host collections from one or more hosts")
    param_group :bulk_params
    param :host_collection_ids, Array, :desc => N_("List of host collection ids"), :required => true
    def bulk_remove_host_collections
      display_messages = []

      unless params[:host_collection_ids].blank?
        @host_collections.each do |host_collection|
          pre_host_collection_count = host_collection.host_ids.count
          host_collection.host_ids =  (host_collection.host_ids - @hosts.map(&:id)).uniq
          host_collection.save!

          final_count = pre_host_collection_count - host_collection.host_ids.count
          display_messages << _("Successfully removed %{count} content host(s) from host collection %{host_collection}.") %
              {:count => final_count, :host_collection => host_collection.name }
        end
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => display_messages }
    end

    api :POST, "/hosts/bulk/applicable_errata",
        N_("Fetch applicable errata for one or more hosts.")
    param_group :bulk_params
    def applicable_errata
      respond_for_index(:collection => scoped_search(Katello::Erratum.applicable_to_hosts(@hosts), 'updated', 'desc',
                                                     :resource_class => Erratum))
    end

    api :POST, "/hosts/bulk/installable_errata",
        N_("Fetch installable errata for one or more hosts.")
    param_group :bulk_params
    def installable_errata
      respond_for_index(:collection => scoped_search(Katello::Erratum.installable_for_hosts(@hosts), 'updated', 'desc',
                                                     :resource_class => Erratum))
    end

    api :PUT, "/hosts/bulk/destroy", N_("Destroy one or more hosts")
    param_group :bulk_params
    def destroy_hosts
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::Destroy, @hosts)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/remove_subscriptions", N_("Remove subscriptions from one or more hosts"), deprecated: true
    param_group :bulk_params
    param :subscriptions, Array, :desc => N_("Array of subscriptions to remove") do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, Integer, :desc => N_("Quantity of specified subscription to remove"), :required => false
    end
    def remove_subscriptions
      #combine the quantities for duplicate pools into PoolWithQuantities objects
      pool_id_quantities = params.require(:subscriptions).inject({}) do |new_hash, subscription|
        new_hash[subscription['id']] ||= PoolWithQuantities.new(Pool.find(subscription['id']))
        new_hash[subscription['id']].quantities << subscription['quantity']
        new_hash
      end
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::RemoveSubscriptions, @hosts, pool_id_quantities.values)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/add_subscriptions", N_("Add subscriptions to one or more hosts"), deprecated: true
    param_group :bulk_params
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => true do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def add_subscriptions
      if @organization.simple_content_access?
        fail HttpErrors::BadRequest, _("The specified organization is in Simple Content Access mode. Attaching subscriptions is disabled")
      end

      pools_with_quantities = params.require(:subscriptions).map do |sub_params|
        PoolWithQuantities.new(Pool.find(sub_params['id']), sub_params['quantity'])
      end

      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::AttachSubscriptions, @hosts, pools_with_quantities)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/auto_attach", N_("Trigger an auto-attach of subscriptions on one or more hosts"), deprecated: true
    param_group :bulk_params
    def auto_attach
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::AutoAttachSubscriptions, @hosts)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/content_overrides", N_("Set content overrides to one or more hosts")
    param_group :bulk_params
    param :content_overrides, Array, :desc => N_("Array of Content override parameters") do
      param :content_label, String, :desc => N_("Label of the content"), :required => true
      param :value, String, :desc => N_("Override value. Provide a boolean value if name is 'enabled'"), :required => false
      param :name, String, :desc => N_("Override key or name. Note if name is not provided the default name will be 'enabled'"), :required => false
      param :remove, :bool, :desc => N_("Set true to remove an override and reset it to 'default'"), :required => false
    end
    def content_overrides
      content_overrides = params[:content_overrides] || []
      content_override_values = content_overrides.map do |content_override_params|
        validate_content_overrides_enabled(content_override_params)
      end

      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::UpdateContentOverrides, @hosts, content_override_values, false)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/environment_content_view", N_("Assign the environment and content view to one or more hosts")
    param_group :bulk_params
    param :environment_id, Integer
    param :content_view_id, Integer
    def environment_content_view
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::UpdateContentView, @hosts, @view.id, @environment.id)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/release_version", N_("Assign the release version to one or more hosts")
    param_group :bulk_params
    param :release_version, String, :desc => N_("content release version")
    def release_version
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::UpdateReleaseVersion, @hosts, params["release_version"])
      respond_for_async :resource => task
    end

    api :POST, "/hosts/bulk/traces", N_("Fetch traces for one or more hosts")
    param_group :bulk_params
    def traces
      collection = scoped_search(Katello::HostTracer.where(host_id: @hosts.pluck(:id)), 'application', 'desc', resource_class: Katello::HostTracer)
      respond_for_index(:collection => collection, :full_template => 'katello/api/v2/host_tracer/index')
    end

    api :PUT, "/hosts/bulk/resolve_traces", N_("Resolve traces for one or more hosts")
    param_group :bulk_params
    param :trace_ids, Array, :required => true, :desc => N_("Array of Trace IDs")
    def resolve_traces
      result = Katello::HostTraceManager.resolve_traces(@traces)

      render json: result
    end

    api :PUT, "/hosts/bulk/system_purpose", N_("Assign system purpose attributes on one or more hosts")
    param_group :bulk_params
    param :service_level, String, :desc => N_("Service level of host")
    param :purpose_role, String, :desc => N_("Role of host")
    param :purpose_usage, String, :desc => N_("Usage of host")
    param :purpose_addons, Array, :desc => N_("Sets the system add-ons")
    def system_purpose
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::UpdateSystemPurpose,
        @hosts,
        params[:service_level],
        params[:purpose_role],
        params[:purpose_usage],
        params[:purpose_addons])

      respond_for_async :resource => task
    end

    api :POST, "/hosts/bulk/available_incremental_updates", N_("Given a set of hosts and errata, lists the content view versions" \
                                                                 " and environments that need updating.")
    param_group :bulk_params
    param :errata_ids, Array, :desc => N_("List of Errata ids"), :required => true
    def available_incremental_updates
      fail HttpErrors::BadRequest, _("errata_ids is a required parameter") if params[:errata_ids].empty?
      version_environments = {}
      content_facets = Katello::Host::ContentFacet.with_non_installable_errata(@errata, @hosts)

      ContentViewEnvironment.for_content_facets(content_facets).each do |cve|
        version = cve.content_view_version
        version_environment = version_environments[version] || {:content_view_version => version, :environments => []}
        version_environment[:environments] << cve.environment unless version_environment[:environments].include?(cve.environment)
        version_environment[:next_version] ||= version.next_incremental_version
        version_environment[:content_host_count] ||= 0
        version_environment[:content_host_count] += content_facets.with_content_view_environments(cve).count

        if version.content_view.composite?
          version_environment[:components] = version.components_needing_errata(@errata)
        else
          version_environment[:components] = nil
        end
        version_environments[version] = version_environment
      end

      response = version_environments.values.map { |version| OpenStruct.new(version) }
      respond_for_index :collection => response, :template => :available_incremental_updates
    end

    api :POST, "/hosts/bulk/module_streams",
        N_("Fetch available module streams for hosts.")
    param_group :bulk_params
    def module_streams
      options = {}
      options[:group] = [:name, :stream]
      options[:resource_class] = Katello::ModuleStream
      host_module_streams = Katello::ModuleStream.available_for_hosts(@hosts)
      respond_for_index(collection: scoped_search(host_module_streams, :name, :asc, options),
                        full_template: 'katello/api/v2/module_streams/name_streams')
    end

    api :PUT, "/hosts/bulk/change_content_source", N_("Update the content source for specified hosts and generate the reconfiguration script")
    param :host_ids, Array, required: true, desc: N_("The ids of the hosts to alter. Hosts not managed by Katello are ignored")
    param :environment_id, :number, required: true, desc: N_("The id of the lifecycle environment")
    param :content_view_id, :number, required: true, desc: N_("The id of the content view")
    param :content_source_id, :number, required: true, desc: N_("The id of the content source")
    def change_content_source
      hosts = ::Host.where(id: params[:host_ids])
      throw_resource_not_found(name: 'host', id: params[:host_ids]) unless hosts.any?

      lifecycle_environment = KTEnvironment.readable.find(params[:environment_id])
      content_view = Katello::ContentView.readable.find(params[:content_view_id])
      content_source = SmartProxy.authorized(:view_smart_proxies).find(params[:content_source_id])
      template = prepare_ssl_cert(foreman_server_ca_cert) + configure_subman(content_source) + reconfigure_yggdrasild(hosts.first)

      hosts.each do |host|
        next unless host.content_facet
        host.content_facet.content_source = content_source
        host.content_facet.assign_single_environment(
          :content_view_id => content_view.id,
          :environment_id => lifecycle_environment.id
        )
        host.update_candlepin_associations
      end

      render plain: template
    end

    private

    def find_errata
      params[:errata_ids] ||= []
      @errata = Katello::Erratum.where(:errata_id => params[:errata_ids])
      not_found = params[:errata_ids] - @errata.pluck(:errata_id)
      fail _("Could not find all specified errata ids: %s") % not_found.join(', ') unless not_found.empty?
    end

    def find_host_collections
      throw_resources_not_found(name: 'host collection', expected_ids: params[:host_collection_ids]) do
        @host_collections = HostCollection.editable.where(id: params[:host_collection_ids])
      end
    end

    def find_readable_hosts
      find_bulk_hosts(:view_hosts, params)
    end

    def find_editable_hosts
      find_bulk_hosts(:edit_hosts, params)
    end

    def find_deletable_hosts
      find_bulk_hosts(:destroy_hosts, params)
    end

    def validate_organization
      fail HttpErrors::BadRequest, _("Organization ID is required") if @organization.blank?
    end

    def validate_host_collection_membership_limit
      max_hosts_exceeded = []
      host_ids = @hosts.map(&:id)

      @host_collections.each do |host_collection|
        computed_count = (host_collection.host_ids + host_ids).uniq.length
        if !host_collection.unlimited_hosts && computed_count > host_collection.max_hosts
          max_hosts_exceeded.push(host_collection.name)
        end
      end

      unless max_hosts_exceeded.empty?
        fail HttpErrors::BadRequest, _("Maximum number of content hosts exceeded for host collection(s): %s") % max_hosts_exceeded.join(', ')
      end
    end

    def find_environment
      @environment = KTEnvironment.editable.find(params[:environment_id])
      throw_resource_not_found(name: 'lifecycle environment', id: params[:environment_id]) unless @environment
      @environment
    end

    def find_content_view
      @view = ContentView.editable.find(params[:content_view_id])
      throw_resource_not_found(name: 'content view', id: params[:content_view_id]) unless @view
      @view
    end

    def find_traces
      throw_resources_not_found(name: 'host trace', expected_ids: params[:trace_ids]) do
        @traces = Katello::HostTracer.resolvable.where(id: params[:trace_ids])
      end
    end

    def disable_erratum_hosts_count
      @disable_counts = true
    end
  end
end
