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

class Api::V1::NodesController < Api::V1::ApiController

  respond_to :json

  before_filter :authorize
  before_filter :find_node, :only => [:destroy, :get, :update, :show, :sync]
  before_filter :find_environment, :only => [:sync]

  def rules
    read_test = lambda { Node.readable? }
    edit_test = lambda { Node.editable? }

    show_by_uuid_test = lambda do
      Node.readable? || User.consumer? && params[:uuid] == current_user.uuid
    end

    create_test = lambda do
      Node.editable? ||
          User.consumer? &&
          params[:node] &&
          params[:node][:system_uuid] == current_user.uuid
    end

    {
      :index                => read_test,
      :show                 => read_test,
      :show_by_uuid         => show_by_uuid_test,
      :create               => create_test,
      :update               => edit_test,
      :destroy              => edit_test,
      :sync                 => edit_test
    }
  end

  def param_rules
    {
      :update => { :node => [:environment_ids] }
    }
  end

  api :GET, "/nodes", "List Katello Nodes"
  def index
    @nodes = Node.all
    respond
  end

  api :GET, "/nodes/:id", "Get details about a node"
  def show
    respond
  end

  api :GET, "/nodes/by_uuid/:uuid", "Get details about a node on a registered system"
  def show_by_uuid
    system = System.find_by_uuid!(params[:uuid])
    @node = Node.find_by_system_id(system.id)
    unless @node
      raise HttpErrors::NotFound, _("System %s is not a registered node") % params[:uuid]
    end
    respond_for_show
  end

  api :POST, "/nodes", "Activate a system as a node"
  param :node, Hash do
    param :system_uuid, String, :required => true, :desc => "Associated system uuid"
    param :environment_ids, Array, :desc => "List of environment ids the node should be associated with"
    param :capabilities, Array, :desc => "List of capabilities" do
      param :type, String, :required => true, :desc => "Type of capability"
      param :configuration, Hash, :desc => "Capability configuration"
    end
  end
  def create
    system = System.find_by_uuid!(params[:node][:system_uuid])
    node_params = { :system_id => system.id }.merge(params[:node].slice(:environment_ids))
    @node = Node.new(node_params)
    @node.save!
    if params[:node][:capabilities]
      params[:node][:capabilities].each do |capability_data|
        cap_class = NodeCapability.class_for(capability_data[:type])
        capability = cap_class.new(capability_data.slice(:configuration))
        capability.node = @node
        capability.save!
      end
    end
    respond
  end

  api :DELETE, "/nodes/:id", "Deactivate a Katello Node"
  def destroy
    @node.destroy
    respond
  end

  api :POST, "/nodes/:id/sync", "Syncronize a Katello node"
  param :environment_id, :identifier, :desc => "Limit sync to a single environment"
  def sync
    task = @node.sync(:environment=>@environment)
    respond_for_async :resource => task
  end

  api :PUT, "/nodes/:id", "Update a Katello Node"
  param :system_id, :identifier, :required => true, :desc=>"Associated system id"
  param :environment_ids, Array, :desc => "List of environment ids the node should be associated with"
  def update
    attrs = params[:node].clone
    @node.update_attributes!(attrs)
    respond :resource => @node
  end

  private

  def find_node
    @node = Node.find(params[:id])
  end

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id]) if params[:environment_id]
  end

end
