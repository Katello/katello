#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# rubocop:disable SymbolName
module Katello
  class Api::V2::SystemsController < Api::V2::ApiController
    respond_to :json

    skip_before_filter :set_default_response_format, :only => :report

    before_filter :find_default_organization_and_or_environment, :only => [:create, :index, :activate]
    before_filter :find_optional_organization, :only => [:create, :hypervisors_update, :index, :activate, :report, :tasks]
    before_filter :find_only_environment, :only => [:create]
    before_filter :find_environment, :only => [:index, :report, :tasks]
    before_filter :find_system_group, :only => [:index]
    before_filter :find_environment_and_content_view, :only => [:create]
    before_filter :find_hypervisor_environment_and_content_view, :only => [:hypervisors_update]
    before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates,
                                          :upload_package_profile, :errata, :package_profile, :subscribe,
                                          :unsubscribe, :subscriptions, :pools, :enabled_repos, :releases,
                                          :add_system_groups, :remove_system_groups, :refresh_subscriptions, :checkin,
                                          :subscription_status] # TODO: this should probably be :except
    before_filter :find_content_view, :only => [:create, :update]

    before_filter :authorize, :except => [:activate, :upload_package_profile]

    def organization_id_keys
      [:organization_id, :owner]
    end

    # TODO: break up this method
    # rubocop:disable MethodLength
    def rules
      index_systems          = index_systems_perms_check
      register_system        = lambda { System.registerable?(@environment, @organization, @content_view) }
      consumer_only          = lambda { User.consumer? }
      edit_system            = lambda do
        subscribable = @content_view ? @content_view.subscribable? : true
        subscribable && (@system.editable? || User.consumer?)
      end
      read_system            = lambda { @system.readable? || User.consumer? }
      delete_system          = lambda { @system.deletable? || User.consumer? }

      # After a system registers, it immediately uploads its packages. Although newer subscription-managers send
      # certificate (User.consumer? == true), some do not. In this case, confirm that the user has permission to
      # register systems in the system's organization and environment.
      upload_system_packages = lambda { @system.editable? || System.registerable?(@system.environment, @system.organization) || User.consumer? }

      {
        :new                              => register_system,
        :create                           => register_system,
        :hypervisors_update               => consumer_only,
        :regenerate_identity_certificates => edit_system,
        :update                           => edit_system,
        :index                            => index_systems,
        :show                             => read_system,
        :subscription_status              => read_system,
        :destroy                          => delete_system,
        :package_profile                  => read_system,
        :errata                           => read_system,
        :upload_package_profile           => upload_system_packages,
        :report                           => index_systems,
        :subscribe                        => edit_system,
        :unsubscribe                      => edit_system,
        :subscriptions                    => read_system,
        :pools                            => read_system,
        :releases                         => read_system,
        :activate                         => register_system,
        :tasks                            => lambda { find_system && @system.readable? },
        :task                             => lambda { true },
        :task_show                        => read_system,
        :enabled_repos                    => consumer_only,
        :add_system_groups                => edit_system,
        :remove_system_groups             => edit_system,
        :refresh_subscriptions            => edit_system,
        :checkin                          => edit_system
      }
    end

    def_param_group :system do
      param :facts, Hash, :desc => "Key-value hash of system-specific facts", :action_aware => true
      param :installedProducts, Array, :desc => "List of products installed on the system", :action_aware => true
      param :name, String, :desc => "Name of the system", :required => true, :action_aware => true
      param :type, String, :desc => "Type of the system, it should always be 'system'", :required => true, :action_aware => true
      param :serviceLevel, String, :allow_nil => true, :desc => "A service level for auto-healing process, e.g. SELF-SUPPORT", :action_aware => true
      param :location, String, :desc => "Physical location of the system"
      param :content_view_id, :identifier
      param :environment_id, :identifier
    end

    api :GET, "/environments/:environment_id/consumers", "List systems (compatibilty)" # according to v2 routes, this should go to v1 controller
    api :GET, "/environments/:environment_id/systems", "List systems in environment"
    api :GET, "/organizations/:organization_id/systems", "List systems in an organization"
    api :GET, "/system_groups/:system_group_id/systems", "List systems in a system group"
    api :GET, "/systems", "List systems"
    param :name, String, :desc => "Filter systems by name"
    param :pool_id, String, :desc => "Filter systems by subscribed pool"
    param :search, String, :desc => "Filter systems by advanced search query"
    param :uuid, String, :desc => "Filter systems by uuid"
    param :organization_id, String, :desc => "Specify the organization", :required => true
    param :environment_id, String, :desc => "Filter by environment"
    param :system_group_id, String, :desc => "Filter by system group"
    def index
      filters = []

      if params[:environment_id]
        filters << {:terms => {:environment_id => [params[:environment_id]] }}
      elsif params[:system_group_id]
        filters << {:terms => {:system_group_id => [params[:system_group_id]] }}
      else
        filters << readable_filters
      end

      filters << {:terms => {:uuid => System.all_by_pool_uuid(params['pool_id']) }} if params['pool_id']
      filters << {:terms => {:uuid => [params['uuid']] }} if params['uuid']

      options = {
        :filters       => filters,
        :load_records? => true
      }
      respond_for_index(:collection => item_search(System, params, options))
    end

    api :POST, "/environments/:environment_id/consumers", "Register a system in environment (compatibility reason)"
    api :POST, "/environments/:environment_id/systems", "Register a system in environment"
    api :POST, "/systems", "Register a system"
    param_group :system
    def create
      @system = System.create!(system_params.merge(:environment  => @environment,
                                                   :content_view => @content_view,
                                                   :serviceLevel => params[:service_level]))
      respond_for_create
    end

    api :PUT, "/consumers/:id", "Update system information (compatibility)"
    api :PUT, "/systems/:id", "Update system information"
    param_group :system
    def update
      super
    end

    api :GET, "/systems/:id", "Show a system"
    param :id, String, :desc => "UUID of the system", :required => true
    def show
      @system_groups = @system.system_groups
      @custom_info = @system.custom_info
      respond
    end

    api :POST, "/systems/:id/system_groups", "Replace existing list of system groups"
    param :system, Hash, :required => true do
      param :system_group_ids, Array, :desc => "List of group ids the system belongs to", :required => true
    end
    def add_system_groups
      ids = params[:system][:system_group_ids] || []
      @system.system_group_ids = ids.uniq
      @system.save!
      respond_for_create
    end

    api :GET, "/systems/:id/packages", "List packages installed on the system"
    param :id, String, :desc => "UUID of the system", :required => true
    def package_profile
      packages = @system.simple_packages.sort { |a, b| a.name.downcase <=> b.name.downcase }
      response = {
        :records  => packages,
        :subtotal => packages.size,
        :total    => packages.size
      }
      respond_for_index :collection => response
    end

    api :PUT, "/systems/:id/refresh_subscriptions", "Trigger a refresh of subscriptions, auto-attaching if enabled"
    param :id, String, :desc => "UUID of the system", :required => true
    def refresh_subscriptions
      @system.refresh_subscriptions
      respond_for_show
    end

    api :GET, "/systems/:id/errata", "List errata available for the system"
    param :id, String, :desc => "UUID of the system", :required => true
    def errata
      errata = @system.errata
      response = {
        :records  => errata.sort_by{ |e| e.issued }.reverse,
        :subtotal => errata.size,
        :total    => errata.size
      }

      respond_for_index :collection => response
    end

    api :GET, "/systems/:id/tasks", "List async tasks for the system"
    def tasks
      @system.refresh_tasks
      query_string = params[:name] ? "name:#{params[:name]}" : params[:search]

      filters = [{:terms => {:task_owner_id => [@system.id]}},
                 {:terms => {:task_owner_type => [System.class_name]}}]
      options = {
        :filters       => filters,
        :load_records? => true,
        :default_field => 'message'
      }
      options[:sort_by] = params[:sort_by] if params[:sort_by]
      options[:sort_order] = params[:sort_order] if params[:sort_order]

      if params[:paged]
        options[:page_size] = params[:page_size] || current_user.page_size
      end

      items = Glue::ElasticSearch::Items.new(TaskStatus)
      tasks, total_count = items.retrieve(query_string, params[:offset], options)

      tasks = {
        :records  => tasks,
        :subtotal => total_count,
        :total    => items.total_items
      }

      respond_for_index(:collection => tasks)
    end

    api :GET, "/systems/task/:task_id", "Grab a single system task"
    param :task_id, String, :desc => "Id of the task", :required => true
    def task
      task = TaskStatus.find(params[:task_id]).refresh
      respond_for_show(:resource => task, :template => :task)
    end

    private

    def find_system
      @system = System.first(:conditions => { :uuid => params[:id] })
      if @system.nil?
        Resources::Candlepin::Consumer.get params[:id] # check with candlepin if system is Gone, raises RestClient::Gone
        fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:id]
      end
    end

    def find_environment
      return unless params.key?(:environment_id)

      @environment = KTEnvironment.find(params[:environment_id])
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @organization = @environment.organization
      @environment
    end

    def find_system_group
      return unless params.key?(:system_group_id)

      @system_group = SystemGroup.find(params[:system_group_id])
      fail HttpErrors::NotFound, _("Couldn't find system group '%s'") % params[:system_group_id] if @system_group.nil?
    end

    def find_only_environment
      if !@environment && @organization && !params.key?(:environment_id)
        if @organization.environments.empty?
          fail HttpErrors::BadRequest, _("Organization %{org} has the '%{env}' environment only. Please create an environment for system registration.") %
            { :org => @organization.name, :env => "Library" }
        end

        # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
        # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
        # this scenario, if the org passed in matches the user's default org, use the default env. If not use
        # the single env of the org or throw an error if more than one.
        #
        if @organization.environments.size > 1
          if current_user.default_environment && current_user.default_environment.organization == @organization
            @environment = current_user.default_environment
          else
            fail HttpErrors::BadRequest, _("Organization %s has more than one environment. Please specify target environment for system registration.") % @organization.name
          end
        else
          if @environment = @organization.environments.first
            return
          end
        end
      end
    end

    def find_environment_and_content_view
      # There are some scenarios (primarily create) where a system may be
      # created using the content_view_environment.cp_id which is the
      # equivalent of "environment_id"-"content_view_id".
      return unless params.key?(:environment_id)

      if params[:environment_id].is_a? String
        if !params.key?(:content_view_id)
          cve = get_content_view_environment_by_cp_id(params[:environment_id])
          @environment = cve.environment
          @organization = @environment.organization
          @content_view = cve.content_view
        else
          # assumption here is :content_view_id is passed as a separate attrib
          @environment = KTEnvironment.find(params[:environment_id])
          @organization = @environment.organization
          fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
        end
        return @environment, @content_view
      else
        find_environment
      end
    end

    def find_content_view
      if (content_view_id = (params[:content_view_id] || params[:system].try(:[], :content_view_id)))
        setup_content_view(content_view_id)
      end
    end

    def readable_filters
      {:terms => {:environment_id => KTEnvironment.systems_readable(@organization).collect { |item| item.id } }}
    end

    def index_systems_perms_check
      lambda do
        perms = [(System.any_readable?(@organization) if @organization),
                 (System.any_readable?(@environment) if @environment),
                 (System.any_readable?(@system_group) if @system_group)]
        perms.compact.inject { |t, v| t && v }
      end
    end

    def system_params
      system_params = params.slice(:name, :owner, :facts, :installedProducts)

      if params.key?(:cp_type)
        system_params[:cp_type] = params[:cp_type]
      elsif params.key?(:type)
        system_params[:cp_type] = params[:type]
      end

      system_params
    end

  end
end
