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


class Api::V2::ContentViewsController < Api::V1::ContentViewsController

  include Api::V2::Rendering

  api :GET, "/content_views/:id"
  param :id, :identifier, :desc => "content view id"
  param :environment_id, :identifier, :desc => "environment id", :required => false
  #TODO: move the logic from as_json to rabl
  def show
    respond :resource => @view
  end

end
