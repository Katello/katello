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
  class Api::V2::RepositorySetsController < Api::V2::ApiController
    respond_to :json

    before_filter :find_product
    before_filter :custom_product?
    before_filter :find_product_content, :except => [:index]

    resource_description do
      api_version "v2"
    end

    api :GET, "/products/:product_id/repository_sets", N_("List repository sets for a product.")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    param :name, String, :required => false, :desc => N_("Repository set name to search on")
    def index
      collection = {}
      collection[:results] = @product.productContent
      # filter on name if it is provided
      collection[:results] = collection[:results].select { |pc| pc.content.name == params[:name] } if params[:name]
      collection[:subtotal] = collection[:results].size
      collection[:total] = collection[:subtotal]
      respond_for_index :collection => collection
    end

    api :GET, "/products/:product_id/repository_sets/:id", N_("Get info about a repository set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    def show
      respond :resource => @product_content
    end

    api :GET, "/products/:product_id/repository_sets/:id/available_repositories", N_("Get list or available repositories for the repository set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    def available_repositories
      scan_cdn = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, @product_content.content.id)
      repos = scan_cdn.output[:results]

      repos = repos.select do |repo|
        if repo[:path].include?('kickstart')
          repo[:substitutions][:releasever].include?('Server') ? repo[:enabled] : true
        else
          true
        end
      end

      collection = {
        :results  => repos,
        :subtotal => repos.size,
        :total    => repos.size
      }
      respond_for_index :collection => collection
    end

    api :PUT, "/products/:product_id/repository_sets/:id/enable", N_("Enable a repository from the set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set to enable")
    param :product_id, :number, :required => true, :desc => N_("ID of the product containing the repository set")
    param :basearch, String, :required => true, :desc => N_("Basearch to enable")
    param :releasever, String, :required => true, :desc => N_("Releasever to enable")
    def enable
      task = sync_task(::Actions::Katello::RepositorySet::EnableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    api :PUT, "/products/:product_id/repository_sets/:id/disable", N_("Disable a repository form the set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set to enable")
    param :product_id, :number, :required => true, :desc => N_("ID of the product containing the repository set")
    param :basearch, String, :required => true, :desc => N_("Basearch to disable")
    param :releasever, String, :required => true, :desc => N_("Releasever to disable")
    def disable
      task = sync_task(::Actions::Katello::RepositorySet::DisableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    private

    def find_product_content
      @product_content = @product.product_content_by_id(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find repository set with id '%s'.") % params[:id] if @product_content.nil?
    end

    def find_product
      @product = Product.find_by_id(params[:product_id])
      fail HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
      @organization = @product.organization
    end

    def custom_product?
      fail _('Repository sets are not available for custom products.') if @product.custom?
    end

    def substitutions
      params.slice(:basearch, :releasever)
    end
  end
end
