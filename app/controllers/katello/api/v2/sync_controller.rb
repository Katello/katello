#
# Copyright 2014 Red Hat, Inc.
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
  class Api::V2::SyncController < Api::V2::ApiController
    before_filter :find_optional_organization, :only => [:index]
    before_filter :find_object, :only => [:index]
    before_filter :ensure_library, :only => [:index]

    api :GET, "/organizations/:organization_id/products/:product_id/sync", N_("Get status of repo synchronisation for given product")
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
      @repository = Repository.syncable.find_by_id(params[:repository_id])
      fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repository.nil?
      @repository
    end

    def ensure_library
      unless @repository.nil?
        fail HttpErrors::NotFound, _("You can check sync status for repositories only in the library lifecycle environment.'") unless @repository.environment.library?
      end
    end
  end
end
