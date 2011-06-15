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

class Api::SyncController < Api::ApiController

  before_filter :find_object, :only => [:index, :show, :create, :cancel]
  respond_to :json

  def index
    # GET /repositories/<id>/sync/
    # list all synces
    render :text => N_("list of syncs"), :status => 200
  end

  def show
    # GET /repositories/<id>/sync/<sync id>
    # get sync status
    render :text => N_("get sync status"), :status => 200
  end

  def create
    # POST /repositories/<id>/sync/
    # start syncing
    @obj.sync
    render :text => "synchronizing  #{@sync_of}: #{@obj.id}", :status => 200
  end

  def cancel
    # DELETE /repositories/<id>/sync/<sync id>
    # cancel the sync action
    @obj.cancel_sync
    render :text => "cancelled synchronization of #{@sync_of}: #{@obj.id}", :status => 200
  end



  def find_provider
    @provider = Provider.find(params[:provider_id])
    render(:text => N_("Couldn't find provider '#{params[:provider_id]}'"), :status => 404) and return if @provider.nil?
    @provider
  end

  def find_product
    @product = Product.find_by_cp_id(params[:product_id])
    render(:text => _("Couldn't find product with id '#{params[:product_id]}'"), :status => 404) and return if @product.nil?
    @product
  end

  def find_repository
    @repository = Glue::Pulp::Repo.find(params[:repository_id])
    render :text => _("Couldn't find repository '#{params[:repository_id]}'"), :status => 404 and return if @repository.nil?
    @repository
  end

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
      render(:text => N_("Couldn't find subject of synchronization"), :status => 404) and return if @obj.nil?
    end
    @obj
  end

end
