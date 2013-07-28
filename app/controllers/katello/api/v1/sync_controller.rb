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
  class Api::V1::SyncController < Api::V1::ApiController

    resource_description do
      description <<-DOC
        methods for handeling repositories synchronisation. Repositories can be selecteted
        individualy by id, by product or by provider
      DOC

      param :organization_id, :identifier, :desc => "oranization identifier", :required => true
      param :product_id, :identifier, :desc => "product identifier", :required => true
      param :provider_id, :identifier, :desc => "provider identifier", :required => true
      param :repository_id, :identifier, :desc => "repository identifier", :required => true

      api_version 'v1'
      api_version 'v2'
    end

    before_filter :find_optional_organization, :only => [:index, :create, :cancel]
    before_filter :find_object, :only => [:index, :create, :cancel]
    before_filter :ensure_library, :only => [:create]
    respond_to :json

    before_filter :authorize

    def rules
      list_test = lambda { Provider.any_readable?(@obj.organization) }
      sync_test = lambda { @obj.organization.syncable? }

      { :index  => list_test,
        :create => sync_test,
        :cancel => sync_test
      }
    end

    api :GET, "/providers/:provider_id/sync", "Get status of repo synchronisation for given provider"
    api :GET, "/organizations/:organization_id/products/:product_id/sync", "Get status of repo synchronisation for given product"
    api :GET, "/repositories/:repository_id/sync", "Get status of synchronisation for given repository"
    def index
      respond_for_show :resource => @obj.sync_status
    end

    api :POST, "/providers/:provider_id/sync", "Synchronize all provider's repositories"
    api :POST, "organizations/:organization_id/products/:product_id/sync", "Synchronise all repositories for given product"
    api :POST, "/repositories/:repository_id/sync", "Synchronise repository"
    def create
      respond_for_index :collection => @obj.sync, :status => 202
    end

    api :DELETE, "/providers/:provider_id/sync", "Cancel running synchronisation for given provider"
    api :DELETE, "/organizations/:organization_id/products/:product_id/sync", "Cancel running synchronisations for given product"
    api :DELETE, "/repositories/:repository_id/sync", "Cancel running synchronisation"
    def cancel
      if @obj.sync_state.to_s == PulpSyncStatus::Status::RUNNING.to_s
        @obj.cancel_sync
        respond_for_destroy :message => _("Synchronization cancelled")
      else
        respond_for_destroy :message => _("No synchronization is currently running")
      end
    end

    private

    # used in unit tests
    def find_object
      if params.key?(:provider_id)
        @obj = find_provider
      elsif params.key?(:product_id)
        @obj = find_product
      elsif params.key?(:repository_id)
        @obj = find_repository
      else
        raise HttpErrors::NotFound, N_("Couldn't find subject of synchronization") if @obj.nil?
      end
      @obj
    end

    def find_provider
      @provider = Provider.find(params[:provider_id])
      raise HttpErrors::BadRequest, N_("Couldn't find provider '%s'") % params[:provider_id] if @provider.nil?
      @provider
    end

    def find_product
      raise _("Organization required") if @organization.nil?
      @product = Product.find_by_cp_id(params[:product_id], @organization)
      raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
      @product
    end

    def find_repository
      @repository = Repository.find(params[:repository_id])
      raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repository.nil?
      @repository
    end

    def ensure_library
      unless @repository.nil?
        raise HttpErrors::NotFound, _("You can synchronize repositories only in library environment'") if not @repository.environment.library?
      end
    end

  end
end
