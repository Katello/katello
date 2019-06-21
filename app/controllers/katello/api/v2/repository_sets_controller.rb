module Katello
  class Api::V2::RepositorySetsController < Api::V2::ApiController
    respond_to :json

    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_product_or_organization
    before_action :custom_product?
    before_action :find_product_content, :except => [:index, :auto_complete_search]

    resource_description do
      api_version "v2"
    end

    api :GET, "/repository_sets", N_("List repository sets.")
    api :GET, "/products/:product_id/repository_sets", N_("List repository sets for a product.")
    param :product_id, :number, :required => false, :desc => N_("ID of a product to list repository sets from")
    param :name, String, :required => false, :desc => N_("Repository set name to search on")
    param :enabled, :bool, :required => false, :desc => N_("If true, only return repository sets that have been enabled. Defaults to false")
    param :with_active_subscription, :bool, :required => false, :desc => N_("If true, only return repository sets that are associated with an active subscriptions")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation, :name, :asc, :resource_class => Katello::ProductContent))
    end

    api :GET, "/repository_sets/:id", N_("Get info about a repository set")
    api :GET, "/products/:product_id/repository_sets/:id", N_("Get info about a repository set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set")
    param :product_id, :number, :required => false, :desc => N_("ID of a product to list repository sets from")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def show
      respond :resource => @product_content
    end

    api :GET, "/repository_sets/:id/available_repositories", N_("Get list of available repositories for the repository set")
    api :GET, "/products/:product_id/repository_sets/:id/available_repositories", N_("Get list of available repositories for the repository set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set")
    param :product_id, :number, :required => false, :desc => N_("ID of a product to list repository sets from")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def available_repositories
      scan_cdn = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, @product_content.content.cp_content_id)
      repos = scan_cdn.output[:results]

      repos = repos.select do |repo|
        if repo[:path].include?('kickstart') && repo[:substitutions][:releasever].present?
          repo[:substitutions][:releasever].include?('.') || repo[:enabled]
        else
          true
        end
      end

      sorted_repos = repos.sort_by do |repo|
        major, minor = repo[:substitutions][:releasever].nil? ? [1000, 1000] : repo[:substitutions][:releasever].split('.').map(&:to_i)
        major = major == 0 ? 1000 : major
        minor = minor.nil? ? 1000 : minor
        arch = repo[:substitutions][:basearch].nil? ? "" : repo[:substitutions][:basearch]

        [arch, major, minor]
      end

      collection = {
        :results => sorted_repos.reverse,
        :subtotal => repos.size,
        :total => repos.size
      }

      respond_for_index :collection => collection
    end

    api :PUT, "/repository_sets/:id/enable", N_("Enable a repository from the set")
    api :PUT, "/products/:product_id/repository_sets/:id/enable", N_("Enable a repository from the set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set to enable")
    param :product_id, :number, :required => false, :desc => N_("ID of the product containing the repository set")
    param :basearch, String, :required => false, :desc => N_("Basearch to enable")
    param :releasever, String, :required => false, :desc => N_("Releasever to enable")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def enable
      task = sync_task(::Actions::Katello::RepositorySet::EnableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    api :PUT, "/repository_sets/:id/disable", N_("Disable a repository from the set")
    api :PUT, "/products/:product_id/repository_sets/:id/disable", N_("Disable a repository from the set")
    param :id, :number, :required => true, :desc => N_("ID of the repository set to disable")
    param :product_id, :number, :required => false, :desc => N_("ID of the product containing the repository set")
    param :basearch, String, :required => false, :desc => N_("Basearch to disable")
    param :releasever, String, :required => false, :desc => N_("Releasever to disable")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def disable
      task = sync_task(::Actions::Katello::RepositorySet::DisableRepository, @product, @product_content.content, substitutions)
      respond_for_async :resource => task
    end

    protected

    def resource_class
      Katello::Content
    end

    def index_relation
      if @product.nil?
        relation = @organization.product_contents.displayable
      else
        relation = @product.displayable_product_contents
      end

      if ::Foreman::Cast.to_bool(params[:enabled])
        relation = relation.enabled(@organization)
      elsif ::Foreman::Cast.to_bool(params[:with_active_subscription])
        relation = relation.with_valid_subscription(@organization)
      else
        relation = relation.where(:id => Katello::ProductContent.with_valid_subscription(@organization)).or(
            relation.where(:id => Katello::ProductContent.enabled(@organization)))
      end

      relation = relation.where(Katello::Content.table_name => {:name => params[:name]}) if params[:name].present?
      relation.redhat
    end

    def find_product_content
      if @product.present?
        @product_content = @product.product_content_by_id(params[:id])
      else
        content = Katello::Content.find_by(:cp_content_id => params[:id], :organization_id => @organization[:id])
        @product_content = Katello::ProductContent.find_by(:content_id => content.id)
      end
      fail HttpErrors::NotFound, _("Couldn't find repository set with id '%s'.") % params[:id] if @product_content.nil?
      @product = @product_content.product if @product.nil?
    end

    def find_product_or_organization
      if params[:product_id]
        find_product
      else
        @organization = find_organization
      end
    end

    def find_product
      @product = Product.find_by(:id => params[:product_id])
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
