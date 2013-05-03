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


class Api::V2::SystemGroupsController < Api::V1::SystemGroupsController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :system_group do
    param :system_group, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true, :desc => "System group name"
      param :description, String
      param :max_systems, Integer, :desc => "Maximum number of systems in the group"
    end
  end

  api :GET, "/system_groups/:id", "Show a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def show
    respond
  end

  api :PUT, "/system_groups/:id", "Update a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param_group :system_group
  def update
    super
  end

  api :GET, "/system_groups/:id/systems", "List systems in the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def systems
    super
  end

  api :POST, "/system_groups/:id/add_systems", "Add systems to the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true do
    param :system_ids, Array, :desc => "Array of system ids"
  end

  def add_systems
    super
  end

  api :POST, "/system_groups/:id/remove_systems", "Remove systems from the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true do
    param :system_ids, Array, :desc => "Array of system ids"
  end
  def remove_systems
    super
  end

  api :GET, "/system_groups/:id/history", "History of jobs performed on a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def history
    super
  end

  api :GET, "/system_groups/:id/history", "History of a job performed on a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :job_id, :identifier, :desc => "Id of a job for filtering"
  def history_show
    super
  end

  api :POST, "/system_groups/:id/copy", "Make copy of a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true, :action_aware => true do
    param :new_name, String, :required => true, :desc => "System group name"
    param :description, String
    param :max_systems, Integer, :desc => "Maximum number of systems in the group"
  end
  def copy
    super
  end

  api :DELETE, "/system_groups/:id", "Destroy a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def destroy
    super
  end

  api :DELETE, "/system_groups/:id/destroy_systems", "Destroy a system group nad contained systems"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def destroy_systems
    super
  end


end
