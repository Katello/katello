module Katello
  class Api::V2::RepositorySetsController < Api::V2::ApiController
    respond_to :json

    before_action :find_product, :except => [:index]
    before_action :find_optional_product, :only => [:index]
    before_action :custom_product?
    before_action :find_product_content, :except => [:index]

    resource_description do
      api_version "v2"
    end

    api :GET, "/products/:product_id/repository_sets", N_("List repository sets for a product.")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    param :name, String, :required => false, :desc => N_("Repository set name to search on")
    param_group :search, Api::V2::ApiController
    def index
      collection = {}
      if @product.nil?
        collection[:results] = available_repository_sets
      else
        collection[:results] = @product.displayable_product_contents
      end
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

    api :GET, "/products/:product_id/repository_sets/:id/available_repositories", N_("Get list of available repositories for the repository set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    def available_repositories
      scan_cdn = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, @product_content.content.id)
      repos = scan_cdn.output[:results]

      repos = repos.select do |repo|
        if repo[:path].include?('kickstart')
          variants = ['Server', 'Client', 'ComputeNode', 'Workstation']
          has_variant = variants.any? { |v| repo[:substitutions][:releasever].include?(v) }
          has_variant ? repo[:enabled] : true
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
    param :basearch, String, :required => false, :desc => N_("Basearch to enable")
    param :releasever, String, :required => false, :desc => N_("Releasever to enable")
    def enable
      task = sync_task(::Actions::Katello::RepositorySet::EnableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    api :PUT, "/products/:product_id/repository_sets/:id/disable", N_("Disable a repository from the set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set to disable")
    param :product_id, :number, :required => true, :desc => N_("ID of the product containing the repository set")
    param :basearch, String, :required => false, :desc => N_("Basearch to disable")
    param :releasever, String, :required => false, :desc => N_("Releasever to disable")
    def disable
      task = sync_task(::Actions::Katello::RepositorySet::DisableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    private

    def find_product_content
      @product_content = @product.product_content_by_id(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find repository set with id '%s'.") % params[:id] if @product_content.nil?
    end

    def find_optional_product
      @product = Product.find_by(:id => params[:product_id])
      @organization = @product.organization unless @product.nil?
      find_organization if @organization.nil?
      @product
    end

    def find_product
      @product = find_optional_product
      fail HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
      @organization = @product.organization
    end

    def custom_product?
      fail _('Repository sets are not available for custom products.') if @product && @product.custom?
    end

    def substitutions
      params.slice(:basearch, :releasever)
    end

    def available_repository_sets
      repository_sets = @organization.products.enabled.uniq.flat_map do |product|
        product.available_content
      end
      repository_sets.uniq.sort_by do |repository_set|
        repository_set.content.name.downcase
      end
    end
  end
end
