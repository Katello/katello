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

class Api::SyncController < Api::ApiController

  before_filter :find_object, :only => [:index, :create, :cancel]
  before_filter :ensure_library, :only => [:create]
  respond_to :json

  before_filter :authorize

  def rules
    list_test = lambda{ Provider.any_readable?(@obj.organization) }
    sync_test = lambda { @obj.organization.syncable? }
    
    { :index => list_test,
      :create => sync_test,
      :cancel => sync_test
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:organization_id/products/:product_id/sync", "List sync"
  api :GET, "/providers/:provider_id/sync", "List sync"
  api :GET, "/repositories/:repository_id/sync", "List sync"
  def index
    render :json => @obj.sync_status
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/organizations/:organization_id/products/:product_id/sync", "Create a sync"
  api :POST, "/providers/:provider_id/sync", "Create a sync"
  api :POST, "/repositories/:repository_id/sync", "Create a sync"
  def create
    to_return = @obj.sync
    render :json => to_return, :status => 202
  end

  def cancel
    if @obj.sync_state.to_s == PulpSyncStatus::Status::RUNNING.to_s
      @obj.cancel_sync
      render :text => "Cancelled synchronization of #{@sync_of}: #{@obj.id}", :status => 200
    else
      render :text => "No synchronization of the #{@sync_of} is currently running", :status => 200
    end
  end
  
  # used in unit tests
  def find_object
    if params.key?(:provider_id)
      @obj = find_provider
      @sync_of = 'provider'
    elsif params.key?(:product_id)
      @obj = find_product
      @sync_of = 'product'
    elsif params.key?(:repository_id)
      @obj = find_repository
      @sync_of = 'repository'
    else
      raise HttpErrors::NotFound, N_("Couldn't find subject of synchronization") if @obj.nil?
    end
    @obj
  end

  private

  def find_provider
    @provider = Provider.find(params[:provider_id])
    raise HttpErrors::BadRequest, N_("Couldn't find provider '#{params[:provider_id]}'") if @provider.nil?
    @provider
  end

  def find_product
    find_organization
    @product = @organization.products.find_by_cp_id(params[:product_id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:product_id]}'") if @product.nil?
    @product
  end

  def find_repository
    @repository = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:repository_id]}'") if @repository.nil?
    @repository
  end

  def ensure_library
    if @sync_of == 'repository'
      raise HttpErrors::NotFound, _("You can synchronize repositories only in library environment'") if not @obj.environment.library?
    end
  end

end
