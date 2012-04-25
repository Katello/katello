#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::RootController < Api::ApiController

  skip_before_filter :authorize # ok - only shows URLs available
  skip_before_filter :require_user

  def resource_list
    all_routes = Rails.application.routes.routes
    api_root_routes = all_routes.select {|r| r.path =~ %r{^/api/[^/]+/:id\(\.:format\)$} }.collect {|r| r.path[0..-(":id(.:format)".length+1)]}.uniq
    api_root_routes.collect! {|r| {:rel => r["/api/".size..-2], :href => r} }

    # provide some fake paths that does not exist (but rhsm is checking it's existance)
    api_root_routes << { :href => '/api/packages/', :rel => 'packages' }

    # katello only APIs
    katello_only = ["/api/templates/",
                    "/api/changesets/",
                    "/api/repositories/",
                    "/api/packages/",
                    "/api/errata/",
                    "/api/disributions/",
                    "/api/tasks/",
                    "/api/gpg_keys/"
                    ]

    # filter out katello-only apis from headpin resource list
    if !AppConfig.katello?
      api_root_routes = api_root_routes.select { |api| !katello_only.include?(api[:href]) }
    end
    render :json => api_root_routes
  end

end
