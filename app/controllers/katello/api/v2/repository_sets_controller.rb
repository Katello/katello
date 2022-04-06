module Katello
  class Api::V2::RepositorySetsController < Api::V2::ApiController
    respond_to :json

    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :set_readable_product_scope, only: [:index, :show, :available_repositories, :auto_complete_search]
    before_action :set_editable_product_scope, only: [:enable, :disable]
    before_action :find_product
    before_action :custom_product?
    before_action :setup_params
    before_action :find_authorized_activation_key, :only => [:index, :auto_complete_search]
    before_action :find_authorized_host, :only => [:index, :auto_complete_search]
    before_action :find_organization
    before_action :find_product_content, :except => [:index, :auto_complete_search]
    before_action :check_airgapped, :only => [:available_repositories, :enable, :disable]

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
    param :with_custom, :bool, :required => false, :desc => N_("If true, return custom repository sets along with redhat repos")
    param :activation_key_id, :number, :desc => N_("activation key identifier"), :required => false
    param :host_id, :number, :desc => N_("Id of the host"), :required => false
    param :content_access_mode_all, :bool, :desc => N_("Get all content available, not just that provided by subscriptions.")
    param :content_access_mode_env, :bool, :desc => N_("Limit content to just that available in the host's or activation key's content view version and lifecycle environment.")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Katello::ProductContent)
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => Katello::ProductContent)
      pcf = ProductContentFinder.wrap_with_overrides(
        product_contents: collection[:results],
        overrides: @consumable&.content_overrides)
      collection[:results] = custom_sort_results(pcf)
      respond(:collection => collection)
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
    param :repository_id, :number, :required => false, :desc => N_("ID of the repository within the set to disable")
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
      Katello::ProductContent
    end

    def index_relation
      if @product.nil?
        authorized_product_contents = Katello::ProductContent.joins(:product).merge(@product_scope)
        relation = @organization.product_contents.merge(authorized_product_contents).displayable
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
      relation = relation.redhat unless ::Foreman::Cast.to_bool(params[:with_custom])
      index_relation_with_consumable_overrides(relation)
    end

    def index_relation_with_consumable_overrides(relation)
      return relation if @consumable.blank?

      content_access_mode_all = ::Foreman::Cast.to_bool(params[:content_access_mode_all])
      content_access_mode_env = ::Foreman::Cast.to_bool(params[:content_access_mode_env])

      content_finder = ProductContentFinder.new(
          :match_subscription => !content_access_mode_all,
          :match_environment => content_access_mode_env,
          :consumable => @consumable)
      relation.merge(content_finder.product_content)
    end

    def find_product_content
      if @product.present?
        @product_content = @product.product_content_by_id(params[:id])
      else
        content = Katello::Content.where(cp_content_id: params[:id], organization: @organization)
        authorized_product_contents = Katello::ProductContent.joins(:product).merge(@product_scope)
        @product_content = authorized_product_contents.joins(:content).merge(content).first
        @product = @product_content&.product
      end
      throw_resource_not_found(name: 'repository set', id: params[:id]) if @product_content.nil?
    end

    def find_product
      if params[:product_id]
        @product = @product_scope.find_by(id: params[:product_id])
        throw_resource_not_found(name: 'product', id: params[:product_id]) if @product.nil?
      end
    end

    def set_readable_product_scope
      @product_scope = Katello::Product.readable
    end

    def set_editable_product_scope
      @product_scope = Katello::Product.editable
    end

    def find_organization
      @organization = @product&.organization || @consumable&.organization || super
    end

    def custom_product?
      fail _('Repository sets are not available for custom products.') if @product&.custom?
    end

    def substitutions
      params.permit(:basearch, :releasever, :repository_id).to_h
    end

    def find_authorized_activation_key
      return unless params[:activation_key_id]
      @activation_key = ActivationKey.readable.find_by(:id => params[:activation_key_id])
      @consumable = @activation_key
      throw_resource_not_found(name: 'activation_key', id: params[:activation_key_id]) if @activation_key.blank?
    end

    def find_authorized_host
      return unless params[:host_id]
      find_host_with_subscriptions(params[:host_id], :view_hosts)
      @consumable = @host.subscription_facet
    end

    def setup_params
      return unless params[:id]
      if params[:entity] == :activation_key
        params[:activation_key_id] ||= params[:id]
      else
        params[:host_id] ||= params[:id]
      end
    end

    def check_airgapped
      if @organization.cdn_configuration.airgapped?
        fail HttpErrors::BadRequest, _("Repositories are not available for enablement while CDN configuration is set to Air-gapped (disconnected).")
      end
    end

    def sort_score(pc) # sort order for enabled
      score = if pc.enabled_content_override&.value == "1"
                4 # overridden to enabled
              elsif pc.enabled_content_override.nil? && pc.enabled
                3 # enabled
              elsif pc.enabled_content_override.nil? && !pc.enabled
                2 # disabled
              elsif pc.enabled_content_override&.value == "0"
                1 # overridden to disabled
              else
                0
              end
      Rails.logger.debug [pc.product_name, pc.enabled_content_override, "Id: #{pc.id}", "Score: #{score}"]
      score
    end

    def custom_sort_results(product_content_finder)
      if params[:sort_by] == 'enabled_by_default' && params[:sort_order] == 'desc'
        product_content_finder.sort { |pca, pcb| sort_score(pca) <=> sort_score(pcb) }.reverse!
      elsif params[:sort_by] == 'enabled_by_default'
        product_content_finder.sort { |pca, pcb| sort_score(pca) <=> sort_score(pcb) }
      else
        product_content_finder
      end
    end
  end
end
