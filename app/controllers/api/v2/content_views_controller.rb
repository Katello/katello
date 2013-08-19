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

  # apipie docs are defined in v1 controller - they remain the same
  def show
    respond :resource => @view
  end

  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier",
        :required                           => false
  param :label, String, :desc => "content view label", :required => false
  param :name, String, :desc => "content view name", :required => false
  param :id, :identifier, :desc => "content view id", :required => false
  def index
    query_params.delete(:environment_id)
    query_params.delete(:organization_id)

    search        = ContentView.where(query_params)
    content_views = if @environment
                       search.readable(@organization).in_environment(@environment)
                     else
                       search.readable(@organization)
                     end

    content_views = {
      :results  => content_views,
      :subtotal => content_views.length,
      :total    => content_views.length
    }

    respond :collection => content_views
  end

end
