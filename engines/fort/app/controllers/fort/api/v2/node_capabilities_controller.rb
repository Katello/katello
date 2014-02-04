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

module Fort
class Api::V2::NodeCapabilitiesController < Katello::Api::V2::ApiController

  before_filter :authorize
  before_filter :find_node
  before_filter :find_capability, :only => [:show, :update, :destroy]

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
      :index   => read_test,
      :show    => read_test,
      :create  => edit_test,
      :update  => edit_test,
      :destroy => edit_test
    }
  end

  api :GET, "/nodes/:id/capabilities", "List Capabilities of a Katello Node"
  param :id, :identifier, :required => true, :desc => "node id"
  def index
    collection = {
      :results  => @node.capabilities,
      :subtotal => @node.capabilities.size,
      :total    => @node.capabilities.size
    }

    respond_for_index(:collection => collection)
  end

  api :GET, "/nodes/:id/capabilities/:type", "Get details about a node capability"
  param :id, :identifier, :required => true, :desc => "node id"
  def show
    respond_for_show(:resource => @capability)
  end

  api :POST, "/nodes/:id/capabilities", "Create a capability for a node"
  param :id, :identifier, :required => true, :desc => "node id"
  param_group :capability
  def create
    cap_class = NodeCapability.class_for(params[:capability][:type])
    capability = cap_class.new(capability_params)
    capability.node = @node
    capability.save!
    respond_for_show(:resource => capability)
  end

  api :DELETE, "/nodes/:id/capabilities/:type", "Remove a capability"
  param :id, :identifier, :required => true, :desc => "node id"
  def destroy
    @capability.destroy
    respond_for_show(:resource => @capability)
  end

  api :PUT, "/nodes/:id/capabilities/:type", "Update a Node Capability"
  param :id, :identifier, :required => true, :desc => "node id"
  param_group :capability
  def update
    @capability.update_attributes!(capability_params)

    respond_for_show(:resource => @capability)
  end

  private

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_capability
    #Note that the user is passing in the type as param :id
    @capability = @node.capabilities.detect{ |c| c.is_a? NodeCapability.class_for(params[:id]) }
  end

  def capability_params
    params.require(:capability).permit(:configuration)
  end

end
end
