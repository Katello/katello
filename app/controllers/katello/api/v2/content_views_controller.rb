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

module Katello
  class Api::V2::ContentViewsController < Api::V2::ApiController

    before_filter :find_organization, :only => [:index]
    before_filter :find_environment, :only => [:index]
    before_filter :authorize

    def rules
      index_test   = lambda { ContentView.any_readable?(@organization) }
      {
        :index                => index_test
      }
    end

    api :GET, "/content_views", "List activation keys"
    api :GET, "/organizations/:organization_id/content_views"
    param_group :search, Api::V2::ApiController
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :environment_id, :identifier, :desc => "environment identifier"
    def index
      content_views = if @environment
                        ContentView.readable(@organization).in_environment(@environment)
                      else
                        ContentView.readable(@organization)
                      end

      content_views = {
          :results  => content_views,
          :subtotal => content_views.length,
          :total    => content_views.length
      }

      respond :collection => content_views
    end

    private

    def find_environment
      return unless params.key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    end
  end
end
