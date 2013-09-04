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

class Api::V1::NodeCapabilitiesController < Api::V1::ApiController

  before_filter :authorize
  before_filter :find_node
  before_filter :find_capability, :only=>[:show, :update, :destroy]
  respond_to :json

  def_param_group :capability do
    param :capability, Hash, :required => true, :action_aware => true do
      param :type, String, :required => true, :desc => "Type of capability"
      param :configuration, Hash, :required => true, :desc => "Capability configuration"
    end
  end

  def rules
    read_test   = lambda{ Node.readable? }
    edit_test   = lambda{ Node.editable? }
    {
      :index                => read_test,
      :show                 => read_test,
      :create               => edit_test,
      :update               => edit_test,
      :destroy              => edit_test
    }
  end

  api :GET, "/nodes/:node_id/capabilities", "List Capabilities of a Katello Node"
  def index
    respond_for_index :collection => @node.capabilities
  end

  api :GET, "/nodes/:node_id/capabilities/:type", "Get details about a node capability"
  def show
    respond :resource => @capability
  end

  api :POST, "/nodes/:node_id/capabilities", "Create a capability for a node"
  param_group :capability
  def create
    cap_class = NodeCapability.class_for(params[:capability][:type])
    capability = cap_class.new(params[:capability].except(:type, :node_id))
    capability.node = @node
    capability.save!
    respond :resource => capability
  end

  api :DELETE, "/nodes/:node_id/capabilities/:type", "Remove a capability"
  def destroy
    @capability.destroy
    respond_for_destroy
  end

  api :PUT, "/nodes/:node_id/capabilities/:type", "Update a Node Capability"
  param_group :capability
  def update
    attrs = params[:capability]
    @capability.update_attributes!(attrs.except(:type, :node_id))

    respond :resource => @capability
  end

  private

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_capability
    #Note that the user is passing in the type as param :id
    @capability = @node.capabilities.detect{ |c| c.is_a? NodeCapability.class_for(params[:id]) }
  end
end
