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

class Api::V2::SyncPlansController < Api::V1::SyncPlansController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :sync_plan do
    param :sync_plan, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "sync plan name", :required => true
      param :interval, SyncPlan::TYPES, :desc => "how often synchronization should run"
      param :sync_date, String, :desc => "start datetime of synchronization"
      param :description, String, :desc => "sync plan description"
    end
  end

  api :GET, "/sync_plans/:id", "Show a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier", :required => true
  def show
    super
  end

  api :PUT, "/sync_plans/:id", "Update a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier", :required => true
  param_group :sync_plan
  def update
    super
  end

  api :DELETE, "/sync_plans/:id", "Destroy a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier"
  def destroy
    super
  end

end
