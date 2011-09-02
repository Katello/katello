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

require 'resources/pulp'

class Api::RepositoriesController < Api::ApiController
  respond_to :json
  before_filter :find_repository, :only => [:show]
  before_filter :find_product, :only => [:create]
  before_filter :find_organization, :only => [:discovery]

  # TODO: define authorization rules
  skip_before_filter :authorize

  def create
    content = @product.add_new_content(params[:name], params[:url], 'yum')
    render :json => content
  end

  def index
    repos = Pulp::Repository.all
    render :json => repos
  end

  def show
    render :json => @repository.to_hash
  end

  # proxy repository discovery call to pulp, so we don't have to create an async task to keep track of async task on pulp side
  def discovery
    pulp_task = Pulp::Repository.start_discovery(params[:url], params[:type])
    task = PulpSyncStatus.using_pulp_task(pulp_task) {|t| t.organization = @organization}
    task.save!
    render :json => task
  end

  def find_repository
    @repository = Glue::Pulp::Repo.find params[:id]
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:id]}'") if @repository.nil?
    @repository
  end

  def find_product
    @product = Product.find_by_cp_id params[:product_id]
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:product_id]}'") if @product.nil?
  end
end
