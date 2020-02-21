module Katello
  class Api::V2::HostsBulkActionsController < Api::V2::ApiController
    include Concerns::Api::V2::BulkHostsExtensions
    include Katello::Concerns::Api::V2::ContentOverridesController

    before_action :find_host_collections, :only => [:bulk_add_host_collections, :bulk_remove_host_collections]
    before_action :find_environment, :only => [:environment_content_view]
    before_action :find_content_view, :only => [:environment_content_view]
    before_action :find_editable_hosts, :except => [:destroy_hosts, :applicable_errata, :installable_errata]
    before_action :find_deletable_hosts, :only => [:destroy_hosts]
    before_action :find_readable_hosts, :only => [:applicable_errata, :installable_errata, :available_incremental_updates]
    before_action :find_errata, :only => [:available_incremental_updates]

    before_action :validate_content_action, :only => [:install_content, :update_content, :remove_content]

    # disable *_count fields on erratum rabl, since they perform N+1 queries
    before_action :disable_erratum_hosts_count

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    PARAM_ACTIONS = {
      :install_content => {
        :package => ::Actions::Katello::Host::Package::Install,
        :package_group => ::Actions::Katello::Host::PackageGroup::Install,
        :errata => :install_errata
      },
      :update_content => {
        :package => ::Actions::Katello::Host::Package::Update,
        :package_group => ::Actions::Katello::Host::PackageGroup::Install
      },
      :remove_content => {
        :package => ::Actions::Katello::Host::Package::Remove,
        :package_group => ::Actions::Katello::Host::PackageGroup::Remove
      }
    }.with_indifferent_access

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
      ::Foreman::Deprecation.api_deprecation_warning("The 'applicable_hosts' field will be removed from this API in Katello 2.0")
      respond_for_index(:collection => scoped_search(Katello::Erratum.applicable_to_hosts(@hosts), 'updated', 'desc',
                                                     :resource_class => Erratum))
    end

    api :POST, "/hosts/bulk/installable_errata",
        N_("Fetch installable errata for one or more hosts.")
    param_group :bulk_params
    def installable_errata
      ::Foreman::Deprecation.api_deprecation_warning("The 'applicable_hosts' field will be removed from this API in Katello 2.0")
      respond_for_index(:collection => scoped_search(Katello::Erratum.installable_for_hosts(@hosts), 'updated', 'desc',
                                                     :resource_class => Erratum))
    end

    api :PUT, "/hosts/bulk/install_content", N_("Install content on one or more hosts")
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package', 'package_group' and 'errata'."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package names, package group names or errata ids)")
    param :install_all, :bool, :desc => N_("Only used for errata, but will install all installable errata.")
    def install_content
      content_action
    end

    api :PUT, "/hosts/bulk/update_content", N_("Update content on one or more hosts")
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package' and 'package_group."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package or package group names)"), :required => true
    param :update_all, :bool, :desc => N_("Updates all packages on the host(s)")
    def update_content
      content_action
    end

    api :PUT, "/hosts/bulk/remove_content", N_("Remove content on one or more hosts")
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package' and 'package_group."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package or package group names)"), :required => true
    def remove_content
      content_action
    end

    api :PUT, "/hosts/bulk/destroy", N_("Destroy one or more hosts")
    param_group :bulk_params
    def destroy_hosts
      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::Destroy, @hosts)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/remove_subscriptions", N_("Remove subscriptions from one or more hosts")
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

    api :PUT, "/hosts/bulk/add_subscriptions", N_("Add subscriptions to one or more hosts")
    param_group :bulk_params
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => true do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def add_subscriptions
      pools_with_quantities = params.require(:subscriptions).map do |sub_params|
        PoolWithQuantities.new(Pool.find(sub_params['id']), sub_params['quantity'])
      end

      task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::AttachSubscriptions, @hosts, pools_with_quantities)
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/bulk/auto_attach", N_("Trigger an auto-attach of subscriptions on one or more hosts")
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

    api :POST, "/hosts/bulk/available_incremental_updates", N_("Given a set of hosts and errata, lists the content view versions" \
                                                                 " and environments that need updating.")
    param_group :bulk_params
    param :errata_ids, Array, :desc => N_("List of Errata ids")
    def available_incremental_updates
      version_environments = {}
      content_facets = Katello::Host::ContentFacet.with_non_installable_errata(@errata, @hosts)

      ContentViewEnvironment.for_content_facets(content_facets).each do |cve|
        version = cve.content_view_version
        version_environment = version_environments[version] || {:content_view_version => version, :environments => []}
        version_environment[:environments] << cve.environment unless version_environment[:environments].include?(cve.environment)
        version_environment[:next_version] ||= version.next_incremental_version
        version_environment[:content_host_count] ||= 0
        version_environment[:content_host_count] += content_facets.where(:content_view_id => cve.content_view).where(:lifecycle_environment_id => cve.environment).count

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
                        template: '../../../api/v2/module_streams/name_streams')
    end

    private

    def find_errata
      params[:errata_ids] ||= []
      @errata = Katello::Erratum.where(:errata_id => params[:errata_ids])
      not_found = params[:errata_ids] - @errata.pluck(:errata_id)
      fail _("Could not find all specified errata ids: %s") % not_found.join(', ') unless not_found.empty?
    end

    def find_host_collections
      @host_collections = HostCollection.where(:id => params[:host_collection_ids])
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

    def content_action
      if params[:content_type] == 'errata'
        options = {}
        options[:update_all] = true if ::Foreman::Cast.to_bool(params[:install_all])
        options[:errata_ids] = params[:content]

        task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::Erratum::ApplicableErrataInstall, @hosts, options)
        respond_for_async :resource => task
      else
        content = params[:content]
        if params[:action] == :update_content && params[:update_all]
          content = []
        end
        task = async_task(::Actions::BulkAction, PARAM_ACTIONS[params[:action]][params[:content_type]], @hosts, content)
        respond_for_async :resource => task
      end
    end

    def validate_content_action
      fail HttpErrors::BadRequest, _("A content_type must be provided.") if params[:content_type].blank?
      fail HttpErrors::BadRequest, _("No content has been provided.") if params[:content].blank? && !params[:update_all]

      if PARAM_ACTIONS[params[:action]][params[:content_type]].nil?
        fail HttpErrors::BadRequest, _("Invalid content type %s") % params[:content_type]
      end
    end

    def find_environment
      @environment = KTEnvironment.find(params[:environment_id])
    end

    def find_content_view
      @view = ContentView.find(params[:content_view_id])
    end

    def disable_erratum_hosts_count
      @disable_counts = true
    end
  end
end
