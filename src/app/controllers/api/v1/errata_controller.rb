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

class Api::V1::ErrataController < Api::V1::ApiController
  respond_to :json

  resource_description do
    error :code => 401, :desc => "Unauthorized"
    error :code => 404, :desc => "Not found"
  end

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

  api :GET, "/errata", "List errata"
  api :GET, "/repositories/:repository_id/errata", "List errata"
  description "Either :repoid or :product_id is required."
  error :code => 400, :desc => "Repo id or environment must be provided"
  param :environment_id, :number, :desc => "Id of environment containing the errata."
  param :product_id, :number, :desc => "The product which contains the errata."
  param :repoid, :number, :desc => "Id of repository containing the errata."
  param :severity, String, :desc => "Severity of errata. Usually one of: Critical, Important, Moderate, Low. Case insensitive."
  param :type, String, :desc => "Type of errata. Usually one of: security, bugfix, enhancement. Case insensitive."
  def index
    filter = params.slice(:repoid, :product_id, :environment_id, :type, :severity).symbolize_keys
    unless filter[:repoid] or filter[:environment_id]
      raise HttpErrors::BadRequest.new(_("Repo ID or environment must be provided"))
    end
    render :json => Errata.filter(filter)
  end

  api :GET, "/repositories/:repository_id/errata/:id", "Show an erratum"
  def show
    render :json => @erratum
  end

  private

  def find_environment
    if params.has_key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    elsif params.has_key?(:repoid)
      @repo = Repository.find(params[:repoid])
      raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repoid] if @repo.nil?
      @environment = @repo.environment
    end
    @environment
  end

  def find_repository
    @repo = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
    @repo
  end

  def find_erratum
    @erratum = Errata.find(params[:id])
    raise HttpErrors::NotFound, _("Erratum with id '%s' not found") % params[:id] if @erratum.nil?
    # and check ownership of it
    raise HttpErrors::NotFound, _("Erratum '%s' not found within the repository") % params[:id] unless @erratum.repoids.include? @repo.pulp_id
    @erratum
  end
end
