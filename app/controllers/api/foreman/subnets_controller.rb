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

class Api::Foreman::SubnetsController < Api::Foreman::SimpleCrudController

  resource_description do
    description <<-DOC
      The Subnet API is available only if support for Foreman is installed.
    DOC
  end

  def_param_group :subnet do
    param :subnet, Hash, :desc => "subnet info", :required => true, :action_aware => true do
      param :name, String, "subnet name", :required => true
    end
  end

  self.foreman_model = ::Foreman::Subnet

  api :GET, "/subnets", "Get list of subnets available in Foreman"
  def index
    super
  end

  api :GET, "/subnets/:id", "Show an subnet"
  param :id, String, "subnet name"
  def show
    super
  end

  api :POST, "/subnet", "Create new subnet in Foreman"
  param_group :subnet
  def create
    super
  end

  api :PUT, "/subnets/:id", "Update an subnet record in Foreman"
  param :id, String, "subnet name"
  param_group :subnet
  def update
    super
  end

  api :DELETE, "/subnets/:id", "Remove an subnet from Foreman"
  param :id, String, "subnet name"
  def destroy
    super
  end
end


