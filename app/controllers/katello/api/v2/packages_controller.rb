#
# Copyright 2014 Red Hat, Inc.
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
  class Api::V2::PackagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package"), :resource => "packages")
    include Katello::Concerns::Api::V2::RepositoryContentController

    api :GET, "/packages", N_("List packages")
    api :GET, "/repositories/:repository_id/packages", N_("List packages")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    private

    def sort_params
      {sort_by: 'nvra'}
    end
  end
end
