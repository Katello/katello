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

class Api::V1::PuppetModulesController < Api::V1::ApiController
  respond_to :json

  before_filter :find_repository
  before_filter :authorize
  before_filter :find_puppet_module, :only => [:show]

  def rules
    readable = lambda { @repo.environment.contents_readable? and @repo.product.readable? }

    {
      :index  => readable,
      :search => readable,
      :show   => readable,
    }
  end

  api :GET, "/repositories/:repository_id/puppet_modules", "List puppet modules"
  param :repository_id, :number, :desc => "repository numeric identifier"
  def index
    respond :collection => @repo.puppet_modules
  end

  api :GET, "/repositories/:repository_id/puppet_modules/search"
  param :repository_id, :number, :desc => "repository numeric identifier"
  param :search, String, :desc => "search expression"
  def search
    puppet_modules = PuppetModule.search(params[:search],
                                         :repoids => @repo.pulp_id,
                                         :page_size => @repo.puppet_module_count,
                                         :default_field => "puppet_name"
                                        )
    respond_for_index :collection => puppet_modules.to_a
  end

  api :GET, "/repositories/:repository_id/puppet_modules/:id", "Show a puppet module"
  param :repository_id, :number, :desc => "repository numeric identifier"
  param :id, String, :desc => "puppet module id"
  def show
    respond
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id])
  end

  def find_puppet_module
    @puppet_module = PuppetModule.find(params[:id])

    unless @puppet_module.repoids.include?(@repo.pulp_id)
      raise HttpErrors::NotFound, _("Puppet module '%{id}' not found within repository '%{repo}'") %
        {:id => params[:id], :repo => @repo.name}
    end
  end
end
