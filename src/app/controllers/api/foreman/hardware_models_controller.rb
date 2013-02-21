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

class Api::Foreman::HardwareModelsController < Api::Foreman::SimpleCrudController

  resource_description do
    description <<-DOC
      The HardwareModels API is available only if support for Foreman is installed.
    DOC
  end

  def_param_group :hardware_model do
    param :hardware_model, Hash, :desc => "hardware model info", :required => true, :action_aware => true do
      param :name, String, :required => true
      param :info, String
      param :vendor_class, String
      param :hardware_model, String
    end
  end

  self.foreman_model = ::Foreman::HardwareModel

  api :GET, "/hardware_models", "Get list of hardware models available in Foreman"
  def index
    super
  end

  api :GET, "/hardware_models/:id", "Show an hardware model"
  param :id, String, "hardware model name"
  def show
    super
  end

  api :POST, "/hardware_models", "Create new hardware model in Foreman"
  param_group :hardware_model
  def create
    super
  end

  api :PUT, "/hardware_models/:id", "Update an hardware model record in Foreman"
  param :id, String, "hardware model name"
  param_group :hardware_model
  def update
    super
  end

  api :DELETE, "/hardware_models/:id", "Remove an hardware model from Foreman"
  param :id, String, "hardware model name"
  def destroy
    super
  end
end


