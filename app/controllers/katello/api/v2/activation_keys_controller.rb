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
    before_filter :find_optional_organization, :only => [:index, :create]
    before_filter :find_activation_key, :only => [:show, :update, :destroy, :available_releases,
                                                  :available_host_collections, :add_host_collections, :remove_host_collections,
                                                  :content_override]
    before_filter :authorize
    before_filter :load_search_service, :only => [:index, :available_host_collections]

    wrap_parameters :include => (ActivationKey.attribute_names + %w(host_collection_ids service_level content_view_environment))

    api :GET, "/activation_keys", N_("List activation keys")
    api :GET, "/environments/:environment_id/activation_keys"
    api :GET, "/organizations/:organization_id/activation_keys"
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :environment_id, :identifier, :desc => N_("environment identifier")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :name, String, :desc => N_("activation key name to filter by")
    param_group :search, Api::V2::ApiController
    def index
      ids = ActivationKey.readable.pluck(:id)
      filters = [:terms => { :id => ids }]
      filters << { :term => {:organization_id => @organization.id} }
      filters << { :terms => {:environment_id => [params[:environment_id]] } } if params[:environment_id]
      filters << { :terms => {:content_view_id => [params[:content_view_id]] } } if params[:content_view_id]
      filters << { :term => { :name => params[:name].downcase } } if params[:name]

      options = {
          :filters       => filters,
          :load_records? => true
      }
      respond_for_index(:collection => item_search(ActivationKey, params, options))
    end

    api :POST, "/activation_keys", N_("Create an activation key")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name"), :required => true
    param :description, String, :desc => N_("description")
    param :environment, Hash, :desc => N_("environment")
    param :environment_id, :identifier, :desc => N_("environment id")
    param :content_view_id, :identifier, :desc => N_("content view id")
    param :usage_limit, :number, :desc => N_("maximum number of registered content hosts, or 'unlimited'")
    def create
      @activation_key = ActivationKey.create!(activation_key_params) do |activation_key|
        activation_key.label ||= labelize_params(params[:activation_key])
        activation_key.environment = @environment if @environment
        activation_key.organization = @organization
        activation_key.user = current_user
      end
      respond
    end

    api :PUT, "/activation_keys/:id", N_("Update an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name"), :required => true
    param :description, String, :desc => N_("description")
    param :environment_id, :identifier, :desc => N_("environment id"), :required => true
    param :content_view_id, :identifier, :desc => N_("content view id"), :required => true
    param :usage_limit, :number, :desc => N_("maximum number of registered content hosts, or 'unlimited'")
    param :release_version, String, :desc => N_("content release version")
    param :service_level, String, :desc => N_("service level")
    def update
      @activation_key.update_attributes!(activation_key_params)
      respond_for_show(:resource => @activation_key)
    end

    api :DELETE, "/activation_keys/:id", N_("Destroy an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    def destroy
      @activation_key.destroy
      respond
    end

    api :GET, "/activation_keys/:id", N_("Show an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    def show
      respond
    end

    api :GET, "/activation_keys/:id/host_collections/available", N_("List host collections the system does not belong to")
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => N_("host collection name to filter by")
    def available_host_collections
      filters = [:terms => {:id => HostCollection.readable.pluck("#{Katello::HostCollection.table_name}.id") -
                   @activation_key.host_collections.pluck("#{Katello::HostCollection.table_name}.id")}]
      filters << {:term => {:name => params[:name].downcase}} if params[:name]

      options = {
          :filters       => filters,
          :load_records? => true
      }

      respond_for_index(:collection => item_search(HostCollection, params, options))
    end

    api :GET, "/activation_keys/:id/releases", N_("Show release versions available for an activation key")
    param :id, String, :desc => N_("ID of the activation key"), :required => true
    def available_releases
      response = {
          :results => @activation_key.available_releases,
          :total => @activation_key.available_releases.size,
          :subtotal => @activation_key.available_releases.size
      }
      respond_for_index :collection => response
    end

    api :PUT, "/activation_keys/:id/host_collections"
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    def add_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids + ids).uniq
      @activation_key.save!
      respond_for_show
    end

    api :DELETE, "/activation_keys/:id/host_collections"
    def remove_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids - ids).uniq
      @activation_key.save!
      respond_for_show
    end

    def content_override
      content_override = params[:content_override]
      @activation_key.set_content_override(content_override[:content_label],
                                           content_override[:name], content_override[:value]) if content_override
      respond_for_show
    end

    private

    def find_environment
      environment_id = params[:environment_id]
      environment_id = params[:environment][:id] if !environment_id && params[:environment]
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

    def find_host_collections
      ids = params[:activation_key][:host_collection_ids] if params[:activation_key]
      @host_collections = []
      if ids
        ids.each do |host_collection_id|
          host_collection = HostCollection.find(host_collection_id)
          fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % host_collection_id if host_collection.nil?
          @host_collections << host_collection
        end
      end
    end

    def verify_presence_of_organization_or_environment
      return if params.key?(:organization_id) || params.key?(:environment_id)
      fail HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
    end

    def activation_key_params
      key_params = params.require(:activation_key).permit(:name,
                                                          :description,
                                                          :environment_id,
                                                          :organization_id,
                                                          :content_view_id,
                                                          :release_version,
                                                          :service_level,
                                                          :content_overrides => [],
                                                          :host_collection_ids => [])

      key_params[:environment_id] = params[:environment][:id] if params[:environment].try(:[], :id)
      key_params[:content_view_id] = params[:content_view][:id] if params[:content_view].try(:[], :id)
      key_params[:usage_limit] = int_limit(params)

      key_params
    end

    def int_limit(key_params)
      limit = key_params[:activation_key].try(:[], :usage_limit)
      if limit.nil?
        limit = -1
      elsif limit == 'unlimited' #_('Unlimited') || limit == 'Unlimited' || limit == _('unlimited') || limit == 'unlimited'
        limit = -1
      else
        limit = Integer(limit) rescue nil
        fail(HttpErrors::BadRequest, _("Invalid usage limit value of '%{value}'") %
            {:value => key_params[:activation_key][:usage_limit]}) if limit.nil?
      end
      limit
    end
  end
end
