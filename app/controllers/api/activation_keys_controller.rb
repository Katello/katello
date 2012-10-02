#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::ActivationKeysController < Api::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:index]
  before_filter :find_environment, :only => [:index, :create]
  before_filter :find_optional_organization, :only => [:index, :update, :destroy, :add_system_groups, :remove_system_groups]
  before_filter :find_activation_key, :only => [:show, :update, :destroy, :add_pool, :remove_pool,
                                                :add_system_groups, :remove_system_groups]
  before_filter :find_pool, :only => [:add_pool, :remove_pool]
  before_filter :find_system_groups, :only => [:add_system_groups, :remove_system_groups]
  before_filter :authorize

  def rules
    read_test = lambda{ActivationKey.readable?(@organization) ||
                        (ActivationKey.readable?(@environment.organization) unless @environment.nil?)}
    manage_test = lambda{ActivationKey.manageable?(@organization) ||
                         (ActivationKey.manageable?(@environment.organization) unless @environment.nil?)}
    {
      :index => read_test,
      :show => read_test,
      :create => manage_test,
      :update => manage_test,
      :add_pool => manage_test,
      :remove_pool => manage_test,
      :destroy => manage_test,
      :add_system_groups => manage_test,
      :remove_system_groups => manage_test
    }
  end

  def param_rules
    {
      :create => {:activation_key => [:name, :description, :system_template_id, :usage_limit]},
      :update => {:activation_key  => [:name, :description, :environment_id, :system_template_id, :usage_limit]}
    }
  end

  api :GET, "/activation_keys", "List activation keys"
  api :GET, "/environments/:environment_id/activation_keys", "List activation keys"
  api :GET, "/organizations/:organization_id/activation_keys", "List activation keys"
  param :name, :identifier, :desc => "lists by activation key name"
  def index
    query_params[:organization_id] = @organization.id unless @organization.nil?
    query_params[:environment_id] = @environment.id unless @environment.nil?

    render :json => ActivationKey.where(query_params)
  end

  api :GET, "/activation_keys/:id", "Show an activation key"
  def show
    render :json => @activation_key
  end

  api :POST, "/activation_keys", "Create an activation key"
  api :POST, "/environments/:environment_id/activation_keys", "Create an activation key"
  param :activation_key, Hash do
    param :name, :identifier, :desc => "activation key identifier (alphanum characters, space, - and _)"
    param :description, String, :allow_nil => true
  end
  def create
    created = ActivationKey.create!(params[:activation_key]) do |ak|
      ak.environment = @environment
      ak.organization = @environment.organization
      ak.user = current_user
    end
    render :json => created
  end

  api :PUT, "/activation_keys/:id", "Update an activation key"
  def update
    @activation_key.update_attributes!(params[:activation_key])
    render :json => ActivationKey.find(@activation_key.id)
  end

  api :POST, "/activation_keys/:id/pools", "Create an entitlement pool within an activation key"
  def add_pool
    @activation_key.key_pools.create(:pool => @pool) unless @activation_key.pools.include?(@pool)
    render :json => @activation_key
  end

  api :DELETE, "/activation_keys/:id/pools/:poolid", "Delete an entitlement pool within an activation key"
  def remove_pool
    unless @activation_key.pools.include?(@pool)
      raise HttpErrors::NotFound, _("Couldn't find pool '%s' in activation_key '%s'") % [@pool.cp_id, @activation_key.name]
    end
    @activation_key.pools.delete(@pool)
    render :json => @activation_key
  end

  api :DELETE, "/activation_keys/:id", "Destroy an activation key"
  def destroy
    @activation_key.destroy
   render :text => _("Deleted activation key '#{params[:id]}'"), :status => 204
  end

  api :POST, "/organizations/:organization_id/activation_keys/:id/system_groups"
  def add_system_groups
    ids = params[:activation_key][:system_group_ids]
    @activation_key.system_group_ids = (@activation_key.system_group_ids + ids).uniq
    @activation_key.save!
    render :json => @activation_key.to_json
  end

  api :DELETE, "/organizations/:organization_id/activation_keys/:id/system_groups"
  def remove_system_groups
    ids = params[:activation_key][:system_group_ids]
    @activation_key.system_group_ids = (@activation_key.system_group_ids - ids).uniq
    @activation_key.save!
    render :json => @activation_key.to_json
  end

  private
  def find_organization
    return unless params.has_key?(:organization_id)

    @organization = Organization.first(:conditions => {:label => params[:organization_id].tr(' ', '_')})
    raise HttpErrors::NotFound, _("Couldn't find organization '%s'") % params[:organization_id]  if @organization.nil?
    @organization
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    @environment
  end

  def find_activation_key
    @activation_key = ActivationKey.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find activation key '%s'") % params[:id] if @activation_key.nil?
    @activation_key
  end

  def find_pool
    @pool = ::Pool.find_by_organization_and_id(@activation_key.organization, params[:poolid])
  end

  def find_system_groups
    ids = params[:activation_key][:system_group_ids] if params[:activation_key]
    @system_groups = []
    if ids
      for group_id in ids
        group = SystemGroup.find(group_id)
        raise HttpErrors::NotFound, _("Couldn't find system group '%s'") % group_id if group.nil?
        @system_groups << group
      end
    end
  end

  def verify_presence_of_organization_or_environment
    return if params.has_key?(:organization_id) or params.has_key?(:environment_id)
    raise HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
  end
end
