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

  api :GET, "/organizations/:organization_id/system_groups/:id", "Show a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def show
    respond
  end
end
