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

class Api::PackagesController < Api::ApiController
  respond_to :json

  before_filter :find_repository
  before_filter :find_package, :only => [:show]
  before_filter :authorize

  def rules
    readable = lambda{ @repo.environment.contents_readable? and @repo.product.readable? }
    {
      :index => readable,
      :search => readable,
      :show => readable,
    }
  end

  api :GET, "/repositories/:repository_id/packages", "List packages"
  param :repository_id, :number, :desc => "environment numeric identifier"
  def index
    render :json => @repo.packages
  end

  api :GET, "/repositories/:repository_id/packages/search"
  param :repository_id, :number, :desc => "environment numeric identifier"
  param :search, String, :desc => "search expression"
  def search
    packages = Package.search(params[:search], 0, 0, [@repo.pulp_id])
    render :json => packages.to_a
  end

  api :GET, "/repositories/:repository_id/packages/:id", "Show a package"
  param :repository_id, :number, :desc => "environment numeric identifier"
  param :id, String, :desc => "package id"
  def show
    render :json => @package
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
    @repo
  end

  def find_package
    @package = Package.find(params[:id])
    raise HttpErrors::NotFound, _("Package with id '%s' not found") % params[:id] if @package.nil?
    # and check ownership of it
    raise HttpErrors::NotFound, _("Package '%s' not found within the repository") % params[:id]  unless @package.repoids.include? @repo.pulp_id
    @package
  end
end
