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

class Api::V2::ErrataController < Api::V2::ApiController

  resource_description do
    error :code => 401, :desc => "Unauthorized"
    error :code => 404, :desc => "Not found"

    api_version 'v2'
  end

  before_filter :find_environment, :only => [:index]
  before_filter :find_repository, :only => [:index, :show]
  before_filter :find_erratum, :only => [:show]
  before_filter :require_repo_or_environment, :only => [:index]
  before_filter :authorize

  def rules
    env_readable = lambda { @environment.contents_readable? }
    readable     = lambda { @repo.environment.contents_readable? && @repo.product.readable? }
    {
        :index => env_readable,
        :show  => readable,
    }
  end


  api :GET, "/repositories/:repository_id/errata", "List errata"
  api :GET, "/environments/:environment_id/errata", "List errata"
  param :environment_id, :number, :desc => "The environment containing the errata."
  param :product_id, :number, :desc => "The product which contains errata."
  param :repository_id, :number, :desc => "The repository which contains errata."
  param :severity, String, :desc => "Severity of errata. Usually one of: Critical, Important, Moderate, Low. Case insensitive."
  param :type, String, :desc => "Type of errata. Usually one of: security, bugfix, enhancement. Case insensitive."
  def index
    filter = params.symbolize_keys.slice(:repository_id, :product_id, :environment_id, :type, :severity)
    respond :collection => Errata.filter(filter)
  end

  api :GET, "/repositories/:repository_id/errata/:id", "Show an erratum"
  def show
    respond :resource => @erratum
  end

  private

  def find_environment
    if params.has_key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @environment
    end
  end

  def find_repository
    if params.has_key?(:repository_id)
      @repo = Repository.find(params[:repository_id])
      raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
      @environment ||= @repo.environment
      @repo
    end
  end

  def find_erratum
    @erratum = Errata.find(params[:id])
    raise HttpErrors::NotFound, _("Erratum with id '%s' not found") % params[:id] if @erratum.nil?
    raise HttpErrors::NotFound, _("Erratum '%s' not found within the repository") % params[:id] unless @erratum.repoids.include? @repo.pulp_id
    @erratum
  end

  def require_repo_or_environment
    raise HttpErrors::BadRequest, _("Either repository or environment is required.") % params[:id] if @repo.nil? && @environment.nil?
  end
end
