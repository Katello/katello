#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class Api::V2::SystemsBulkActionsController < Api::V2::ApiController
    include Concerns::Api::V2::BulkSystemsExtensions

    before_filter :find_organization
    before_filter :find_host_collections, :only => [:bulk_add_host_collections, :bulk_remove_host_collections]
    before_filter :find_environment, :only => [:environment_content_view]
    before_filter :find_content_view, :only => [:environment_content_view]
    before_filter :load_search_service
    before_filter :find_editable_systems, :except => [:destroy_systems, :applicable_errata]
    before_filter :find_deletable_systems, :only => [:destroy_systems]
    before_filter :find_readable_systems, :only => [:applicable_errata, :available_incremental_updates]
    before_filter :find_errata, :only => [:available_incremental_updates]

    before_filter :validate_content_action, :only => [:install_content, :update_content, :remove_content]

    PARAM_ACTIONS = {
      :install_content => {
        :package => :install_packages,
        :package_group => :install_package_groups,
        :errata => :install_errata
      },
      :update_content => {
        :package => :update_packages,
        :package_group => :update_package_groups
      },
      :remove_content => {
        :package => :uninstall_packages,
        :package_group => :uninstall_package_groups
      }
    }.with_indifferent_access

    def_param_group :bulk_params do
      param :organization_id, :identifier, :required => true, :desc => N_("ID of the organization")
      param :included, Hash, :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for systems to perform an action on")
        param :ids, Array, :required => false, :desc => N_("List of system ids to perform an action on")
      end
      param :excluded, Hash, :required => true, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of system ids to exclude and not run an action on")
      end
    end

    api :PUT, "/systems/bulk/add_host_collections",
        N_("Add one or more host collections to one or more content hosts"), :deprecated => true
    param_group :bulk_params
    param :host_collection_ids, Array, :desc => N_("List of host collection ids"), :required => true
    def bulk_add_host_collections
      unless params[:host_collection_ids].blank?
        display_messages = []

        @host_collections.each do |host_collection|
          pre_host_collection_count = host_collection.system_ids.count
          host_collection.system_ids =  (host_collection.system_ids + @systems.collect { |s| s.id }).uniq
          host_collection.save!

          final_count = host_collection.system_ids.count - pre_host_collection_count
          display_messages << _("Successfully added %{count} content host(s) to host collection %{host_collection}.") %
              {:count => final_count, :host_collection => host_collection.name }
        end
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => display_messages }
    end

    api :PUT, "/systems/bulk/remove_host_collections",
        N_("Remove one or more host collections from one or more content hosts"), :deprecated => true
    param_group :bulk_params
    param :host_collection_ids, Array, :desc => N_("List of host collection ids"), :required => true
    def bulk_remove_host_collections
      display_messages = []

      unless params[:host_collection_ids].blank?
        @host_collections.each do |host_collection|
          pre_host_collection_count = host_collection.system_ids.count
          host_collection.system_ids =  (host_collection.system_ids - @systems.collect { |s| s.id }).uniq
          host_collection.save!

          final_count = pre_host_collection_count - host_collection.system_ids.count
          display_messages << _("Successfully removed %{count} content host(s) from host collection %{host_collection}.") %
              {:count => final_count, :host_collection => host_collection.name }
        end
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => display_messages }
    end

    api :POST, "/systems/bulk/applicable_errata",
        N_("Fetch applicable errata for a system."), :deprecated => true
    param_group :bulk_params
    def applicable_errata
      respond_for_index(:collection => scoped_search(Katello::Erratum.installable_for_systems(@systems), 'updated', 'desc',
                                                     :resource_class => Erratum))
    end

    api :PUT, "/systems/bulk/install_content", N_("Install content on one or more systems"), :deprecated => true
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package', 'package_group' and 'errata'."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package names, package group names or errata ids)"), :required => true
    def install_content
      content_action
    end

    api :PUT, "/systems/bulk/update_content", N_("Update content on one or more systems"), :deprecated => true
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package' and 'package_group."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package or package group names)"), :required => true
    def update_content
      content_action
    end

    api :PUT, "/systems/bulk/remove_content", N_("Remove content on one or more systems"), :deprecated => true
    param_group :bulk_params
    param :content_type, String,
          :desc => N_("The type of content.  The following types are supported: 'package' and 'package_group."),
          :required => true
    param :content, Array, :desc => N_("List of content (e.g. package or package group names)"), :required => true
    def remove_content
      content_action
    end

    api :PUT, "/systems/bulk/destroy", N_("Destroy one or more systems"), :deprecated => true
    param_group :bulk_params
    def destroy_systems
      @systems.each { |system| sync_task(::Actions::Katello::System::Destroy, system) }
      display_message = _("Successfully removed %s content host(s)") % @systems.length
      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => [display_message] }
    end

    api :PUT, "/systems/bulk/environment_content_view", N_("Assign the environment and content view to one or more systems"), :deprecated => true
    param_group :bulk_params
    param :environment_id, Integer
    param :content_view_id, Integer
    def environment_content_view
      @systems.each do |system|
        system.content_view = @view
        system.environment = @environment
        system.save!
      end
      display_message = _("Successfully reassigned %{count} content host(s) to %{cv} in %{env}.") %
          {:count => @systems.length, :cv => @view.name, :env => @environment.name}
      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => [display_message] }
    end

    api :POST, "/systems/bulk/available_incremental_updates", N_("Given a set of systems and errata, lists the content view versions \
                                                                  and environments that need updating."), :deprecated => true
    param_group :bulk_params
    param :errata_ids, Array, :desc => N_("List of Errata ids")
    def available_incremental_updates
      version_environments = {}
      systems = System.with_non_installable_errata(@errata).where("#{System.table_name}.id" => @systems)

      ContentViewEnvironment.for_systems(systems).each do |cve|
        version = cve.content_view_version
        version_environment = version_environments[version] || {:content_view_version => version, :environments => []}
        version_environment[:environments] << cve.environment unless version_environment[:environments].include?(cve.environment)
        version_environment[:next_version] ||= version.next_incremental_version
        version_environment[:content_host_count] ||= 0
        version_environment[:content_host_count] += systems.where(:content_view_id => cve.content_view).where(:environment_id => cve.environment).count

        if version.content_view.composite?
          version_environment[:components] = version.components_needing_errata(@errata)
        else
          version_environment[:components] = nil
        end

        version_environments[version] = OpenStruct.new(version_environment)
      end

      respond_for_index :collection => version_environments.values, :template => :available_incremental_updates
    end

    private

    def find_errata
      @errata = Katello::Erratum.where(:uuid => params[:errata_ids])
      not_found = params[:errata_ids] - @errata.pluck(:uuid)
      fail _("Could not find all specified errata ids: %s") % not_found.join(', ') unless not_found.empty?
    end

    def find_host_collections
      @host_collections = HostCollection.where(:id => params[:host_collection_ids])
    end

    def find_readable_systems
      find_bulk_systems(:readable, params)
    end

    def find_editable_systems
      find_bulk_systems(:editable, params)
    end

    def find_deletable_systems
      find_bulk_systems(:deletable, params)
    end

    def validate_host_collection_membership_limit
      max_content_hosts_exceeded = []
      system_ids = @systems.collect { |i| i.id }

      @host_collections.each do |host_collection|
        computed_count = (host_collection.system_ids + system_ids).uniq.length
        if !host_collection.unlimited_content_hosts && computed_count > host_collection.max_content_hosts
          max_content_hosts_exceeded.push(host_collection.name)
        end
      end

      unless max_content_hosts_exceeded.empty?
        fail HttpErrors::BadRequest, _("Maximum number of content hosts exceeded for host collection(s): %s") % max_content_hosts_exceeded.join(', ')
      end
    end

    def content_action
      if params[:content_type] == 'errata'
        errata_uuids = Katello::Erratum.where(:errata_id => params[:content]).pluck(:uuid)
        errata_uuids += Katello::Erratum.where(:uuid => params[:content]).pluck(:uuid)
        task = async_task(::Actions::BulkAction, ::Actions::Katello::System::Erratum::ApplicableErrataInstall, @systems, errata_uuids.uniq)
        respond_for_async :resource => task
      else
        action = Katello::BulkActions.new(User.current, @organization, @systems)
        job = action.send(PARAM_ACTIONS[params[:action]][params[:content_type]],  params[:content])
        respond_for_show :template => 'job', :resource => job
      end
    end

    def validate_content_action
      fail HttpErrors::BadRequest, _("A content_type must be provided.") if params[:content_type].blank?
      fail HttpErrors::BadRequest, _("No content has been provided.") if params[:content].blank?

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
  end
end
