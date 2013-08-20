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

class Api::V2::NodesController < Api::V1::NodesController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :node do
    param :node, Hash, :required => true, :action_aware => true do
      param :system_id, Integer, :desc => "System Id", :required => true
      param :environment_ids, Array, :desc => "Environment Ids"
    end
  end

end
