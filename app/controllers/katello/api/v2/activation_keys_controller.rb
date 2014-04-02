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
  class Api::V2::ActivationKeysController < Api::V2::ApiController

    before_filter :verify_presence_of_organization_or_environment, :only => [:index]
    before_filter :find_environment, :only => [:index, :create, :update]
    before_filter :find_optional_organization, :only => [:index]
    before_filter :find_activation_key, :only => [:show, :update,
                                                  :available_system_groups, :add_system_groups, :remove_system_groups]
    before_filter :authorize
    before_filter :load_search_service, :only => [:index, :available_system_groups]

    wrap_parameters :include => (ActivationKey.attribute_names + %w(system_group_ids))

    def rules
      read_test   = lambda do
        ActivationKey.readable?(@organization) ||
          (ActivationKey.readable?(@environment.organization) unless @environment.nil?)
      end
      manage_test = lambda do
        ActivationKey.manageable?(@organization) ||
          (ActivationKey.manageable?(@environment.organization) unless @environment.nil?)
      end
      {
        :index                => read_test,
        :show                 => read_test,
        :create               => manage_test,
        :update               => manage_test,
        :available_system_groups  => manage_test,
        :add_system_groups        => manage_test,
        :remove_system_groups     => manage_test
      }
    end

    api :GET, "/activation_keys", "List activation keys"
    api :GET, "/environments/:environment_id/activation_keys"
    api :GET, "/organizations/:organization_id/activation_keys"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :environment_id, :identifier, :desc => "environment identifier"
    param :content_view_id, :identifier, :desc => "content view identifier"
    param :name, String, :desc => "activation key name to filter by"
    param_group :search, Api::V2::ApiController
    def index
      query_string = ActivationKey.readable(@organization)
      query_string = query_string.where(:environment_id => params[:environment_id]) if params[:environment_id]
      query_string = query_string.where(:content_view_id => params[:content_view_id]) if params[:content_view_id]

      filters = [:terms => { :id => query_string.pluck(:id) }]
      filters << {:term => { :name => params[:name].downcase} } if params[:name]

      options = {
          :filters       => filters,
          :load_records? => true
      }
      respond_for_index(:collection => item_search(ActivationKey, params, options))
    end

    api :POST, "/activation_keys", "Create an activation key"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :name, String, :desc => "name", :required => true
    param :label, String, :desc => "unique label"
    param :description, String, :desc => "description"
    param :environment, Hash, :desc => "environment"
    param :environment_id, :identifier, :desc => "environment id", :required => true
    param :content_view_id, :identifier, :desc => "content view id", :required => true
    param :usage_limit, :number, :desc => "maximum number of uses"
    def create
      @activation_key = ActivationKey.create!(activation_key_params) do |activation_key|
        activation_key.environment = @environment
        activation_key.organization = @environment.organization
        activation_key.user = current_user
      end
      respond
    end

    api :PUT, "/activation_keys/:id", "Update a activation key"
    param :id, :identifier, :desc => "ID of the activation key", :required => true
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :name, String, :desc => "name", :required => true
    param :description, String, :desc => "description"
    param :environment_id, :identifier, :desc => "environment id", :required => true
    param :content_view_id, :identifier, :desc => "content view id", :required => true
    param :usage_limit, :number, :desc => "maximum number of uses"
    def update
      @activation_key.update_attributes(activation_key_params)
      respond
    end

    api :GET, "/activation_keys/:id", "Show an activation key"
    param :id, :identifier, :desc => "ID of the activation key", :required => true
    def show
      respond
    end

    api :GET, "/activation_keys/:id/system_groups/available", "List system groups the system does not belong to"
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => "system group name to filter by"
    def available_system_groups
      filters = [:terms => {:id => SystemGroup.readable(@activation_key.organization).pluck("#{Katello::SystemGroup.table_name}.id") -
                   @activation_key.system_groups.pluck("#{Katello::SystemGroup.table_name}.id")}]
      filters << {:term => {:name => params[:name].downcase}} if params[:name]

      options = {
          :filters       => filters,
          :load_records? => true
      }

      respond_for_index(:collection => item_search(SystemGroup, params, options))
    end

    api :PUT, "/activation_keys/:id/system_groups"
    param :id, :identifier, :desc => "ID of the activation key", :required => true
    def add_system_groups
      ids = activation_key_params[:system_group_ids]
      @activation_key.system_group_ids = (@activation_key.system_group_ids + ids).uniq
      @activation_key.save!
      respond_for_show
    end

    api :DELETE, "/activation_keys/:id/system_groups"
    def remove_system_groups
      ids = activation_key_params[:system_group_ids]
      @activation_key.system_group_ids = (@activation_key.system_group_ids - ids).uniq
      @activation_key.save!
      respond_for_show
    end

    private

    def find_environment
      environment_id = params[:environment_id]
      environment_id = params[:environment][:id] if !environment_id && params.key?(:environment)
      return if !environment_id

      @environment = KTEnvironment.find(environment_id)
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @organization = @environment.organization
      @environment
    end

    def find_activation_key
      @activation_key = ActivationKey.find(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % params[:id] if @activation_key.nil?
      @activation_key
    end

    def find_pool
      @pool = Pool.find_by_organization_and_id(@activation_key.organization, params[:poolid])
    end

    def find_system_groups
      ids = params[:activation_key][:system_group_ids] if params[:activation_key]
      @system_groups = []
      if ids
        ids.each do |group_id|
          group = SystemGroup.find(group_id)
          fail HttpErrors::NotFound, _("Couldn't find system group '%s'") % group_id if group.nil?
          @system_groups << group
        end
      end
    end

    def verify_presence_of_organization_or_environment
      return if params.key?(:organization_id) || params.key?(:environment_id)
      fail HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
    end

    def activation_key_params
      if params[:environment] && params[:environment][:id]
        params[:environment_id] = params[:environment][:id]
        params.delete(:environment)
      end
      if params[:content_view] && params[:content_view][:id]
        params[:content_view_id] = params[:content_view][:id]
        params.delete(:content_view)
      end
      attrs = [:name, :description, :environment_id, :usage_limit, :organization_id, :content_view_id,
               :system_group_ids => []]
      params.require(:activation_key).permit(*attrs)
    end
  end
end
