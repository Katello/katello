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


class Api::V2::SystemsController < Api::V1::SystemsController

  include Api::V2::Rendering

  def_param_group :system do
    param :facts, Hash, :desc => "Key-value hash of system-specific facts", :action_aware => true
    param :installedProducts, Array, :desc => "List of products installed on the system", :action_aware => true
    param :name, String, :desc => "Name of the system", :required => true, :action_aware => true
    param :type, String, :desc => "Type of the system, it should always be 'system'", :required => true, :action_aware => true
    param :serviceLevel, String, :allow_nil => true, :desc => "A service level for auto-healing process, e.g. SELF-SUPPORT", :action_aware => true
    param :location, String, :desc => "Physical of the system"
    param :content_view_id, :identifier
    param :environment_id, :identifier
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

end
