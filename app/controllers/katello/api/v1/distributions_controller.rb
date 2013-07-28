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
  class Api::V1::DistributionsController < Api::V1::ApiController
    respond_to :json

    before_filter :find_repository
    before_filter :check_distribution, :only => [:show]
    before_filter :authorize

    def rules
      readable = lambda { @repo.environment.contents_readable? and @repo.product.readable? }
      {
          :index => readable,
          :show  => readable,
      }
    end

    api :GET, "/repositories/:repository_id/distributions", "List distributions"
    def index
      respond :collection => @repo.distributions
    end

    api :GET, "/repositories/:repository_id/distributions/:id", "Show a distribution"
    param :repository_id, :number, :desc => "repository numeric id"
    def show
      dist = Distribution.find(params[:id])
      respond :resource => dist
    end

    private

    def find_repository
      @repo = Repository.find(params[:repository_id])
      raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
      @repo
    end

    def check_distribution
      raise HttpErrors::NotFound, _("Distribution '%s' not found within the repository") % params[:id] unless @repo.has_distribution? params[:id]
    end

  end
end
