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

class Api::ErrataController < Api::ApiController
  respond_to :json

  before_filter :find_environment, :only => [:index]
  before_filter :find_repository, :except => [:index]
  before_filter :find_erratum, :except => [:index]
  before_filter :authorize

  def rules
    env_readable = lambda{ @environment.contents_readable? }
    readable = lambda{ @repo.environment.contents_readable? and @repo.product.readable? }
    {
      :index => env_readable,
      :show => readable,
    }
  end

  def index
    filter = params.slice(:repoid, :product_id, :environment_id, :type, :severity).symbolize_keys
    unless filter[:repoid] or filter[:environment_id]
      raise HttpErrors::BadRequest.new(_("Repo id or environment must be provided"))
    end
    render :json => Glue::Pulp::Errata.filter(filter)
  end

  def show
    render :json => @erratum
  end

  private

  def find_environment
    if params.has_key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    elsif params.has_key?(:repoid)
      @repo = Repository.find(params[:repoid])
      raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:repoid]}'") if @repo.nil?
      @environment = @repo.environment
    end
    @environment
  end

  def find_repository
    @repo = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:repository_id]}'") if @repo.nil?
    @repo
  end

  def find_erratum
    @erratum = Glue::Pulp::Errata.find(params[:id])
    raise HttpErrors::NotFound, _("Erratum with id '#{params[:id]}' not found") if @erratum.nil?
    # and check ownership of it
    raise HttpErrors::NotFound, _("Erratum '#{params[:id]}' not found within the repository") unless @erratum.repoids.include? @repo.pulp_id
    @erratum
  end
end
