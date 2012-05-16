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

require_dependency 'resources/pulp' if AppConfig.katello?

class Api::DistributionsController < Api::ApiController
  respond_to :json

  before_filter :find_repository
  before_filter :check_distribution, :only => [:show]
  before_filter :authorize

  def rules
    readable = lambda{ @repo.environment.contents_readable? and @repo.product.readable? }
    {
      :index => readable,
      :show => readable,
    }
  end

  def index
    render :json => @repo.distributions
  end

  def show
    dist = Glue::Pulp::Distribution.find(params[:id])
    render :json => dist
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:repository_id]}'") if @repo.nil?
    @repo
  end

  def check_distribution
    raise HttpErrors::NotFound, _("Distribution '#{params[:id]}' not found within the repository") unless @repo.has_distribution? params[:id]
  end

end
