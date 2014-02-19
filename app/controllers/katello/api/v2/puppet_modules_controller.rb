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
class Api::V2::PuppetModulesController < Api::V2::ApiController
  before_filter :find_repository
  before_filter :find_environment, :only => [:index]
  before_filter :authorize
  before_filter :find_puppet_module, :only => [:show]

  def rules
    readable = lambda do
      (@environment && @environment.contents_readable?) ||
      (@repo.environment.contents_readable? && @repo.product.readable?)
    end

    {
        :index  => readable,
        :show   => readable,
    }
  end

  api :GET, "/puppet_modules", "List puppet modules"
  api :GET, "/environments/:environment_id/puppet_modules", "List puppet modules"
  api :GET, "/repositories/:repository_id/puppet_modules", "List puppet modules"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  def index
    repoids = if @repo && @repo.puppet?
                [@repo.pulp_id]
              elsif @environment
                @environment.puppet_repositories.map(&:pulp_id)
              else
                []
              end

    options = sort_params
    options[:filters] = [{ :terms => { :repoids => repoids } }]

    @search_service.model = PuppetModule
    respond(:collection => item_search(PuppetModule, params, options))
  end

  api :GET, "/puppet_modules/:id", "Show a puppet module"
  api :GET, "/repositories/:repository_id/puppet_modules/:id", "Show a puppet module"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  param :id, String, :desc => "puppet module identifier", :required => true
  def show
    respond :resource => @puppet_module
  end

  private

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id]) if params[:environment_id]
  end

  def find_repository
    @repo = Repository.find(params[:repository_id]) if params[:repository_id]
  end

  def find_puppet_module
    @puppet_module = PuppetModule.find(params[:id])
    fail HttpErrors::NotFound, _("Puppet module with id '%s' not found") % params[:id] if @puppet_module.nil?

    unless @puppet_module.repoids.include?(@repo.pulp_id)
      fail HttpErrors::NotFound, _("Puppet module '%{id}' not found within repository '%{repo}'") %
          { :id => params[:id], :repo => @repo.name }
    end
  end

end
end
