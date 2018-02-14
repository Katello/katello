module Katello
  class Api::V2::RepositorySetsController < Api::V2::ApiController
    respond_to :json

    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_product, :except => [:index, :auto_complete_search]
    before_action :find_optional_product, :only => [:index, :auto_complete_search]
    before_action :custom_product?
    before_action :find_product_content, :except => [:index, :auto_complete_search]

    resource_description do
      api_version "v2"
    end

    api :GET, "/products/:product_id/repository_sets", N_("List repository sets for a product.")
    param :product_id, :number, :required => true, :desc => N_("ID of a product to list repository sets from")
    param :name, String, :required => false, :desc => N_("Repository set name to search on")
    param :enabled, :bool, :required => false, :desc => N_("If true, only return repository sets that have been enabled. Defaults to false")
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation, nil, nil, :custom_sort => default_sort,
                                           :resource_class => Katello::ProductContent))
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
      scan_cdn = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, @product_content.content.cp_content_id)
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

    protected

    def resource_class
      Katello::Content
    end

    def default_sort
      lambda { |relation| relation.joins(:content).order("#{Katello::Content.table_name}.name asc") }
    end

    def index_relation
      if @product.nil?
        relation = @organization.product_contents.displayable
      else
        relation = @product.displayable_product_contents
      end

      relation = relation.enabled(@organization) if ::Foreman::Cast.to_bool(params[:enabled])
      relation = relation.joins(:content).where(:name => params[:name]) if params[:name].present?
      relation.redhat
    end

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
      params.permit(:basearch, :releasever).to_h
    end
  end
end
