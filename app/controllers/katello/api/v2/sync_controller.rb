module Katello
  class Api::V2::SyncController < Api::V2::ApiController
    before_action :find_optional_organization, :only => [:index]
    before_action :find_object, :only => [:index]
    before_action :ensure_library, :only => [:index]

    api :GET, "/repositories/:repository_id/sync", N_("Get status of synchronisation for given repository")
    def index
      respond_for_async(:resource => @obj.sync_status)
    end

    private

    # used in unit tests
    def find_object
      if params.key?(:product_id)
        @obj = find_product
      elsif params.key?(:repository_id)
        @obj = find_repository
      else
        fail HttpErrors::NotFound, N_("Couldn't find subject of synchronization") if @obj.nil?
      end
      @obj
    end

    def find_product
      fail _("Organization required") if @organization.nil?
      @product = Product.syncable.find_by_cp_id(params[:product_id], @organization)
      fail HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
      @product
    end

    def find_repository
      @repository = Repository.syncable.find_by(:id => params[:repository_id])
      fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repository.nil?
      @repository
    end

    def ensure_library
      if !@repository.nil? && !@repository.environment.library?
        fail HttpErrors::NotFound, _("You can check sync status for repositories only in the library lifecycle environment.'")
      end
    end
  end
end
