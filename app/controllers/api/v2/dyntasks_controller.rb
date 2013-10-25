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

class Api::V2::DyntasksController < Api::V2::ApiController

  before_filter :authorize

  def rules
    test = lambda do
      # TODO
      return true
    end
    {
      :index => test,
    }
  end

  api :GET, "/organizations/:organization_id/dyntasks", "List dynflow tasks for uuids"
  param :uuids, Array, :desc => 'List of uuids to fetch info about'
  def index
    uuids = Array(params[:uuids])
    # TODO: remove after upading to angular >= 1.1.3 supporting arrays in query params
    # https://github.com/angular/angular.js/commit/2a2123441c2b749b8f316a24c3ca3f77a9132a01
    uuids = uuids.map { |uuid| uuid.split(',') }.flatten

    render :json => uuids.map { |uuid| { :uuid => uuid, :progress => rand } }
  end

end
