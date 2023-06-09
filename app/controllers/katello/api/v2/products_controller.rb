module Katello
  class Api::V2::ProductsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_activation_key, :only => [:index]
    before_action :find_organization, :only => [:create, :index, :auto_complete_search]
    before_action :find_authorized_katello_resource, :only => [:update, :destroy, :sync]
    before_action :find_organization_from_product, :only => [:update]
    before_action :authorize_gpg_key, :only => [:update, :create]
    before_action :authorize_ssl_ca_cert, :only => [:update, :create]
    before_action :authorize_ssl_client_cert, :only => [:update, :create]
    before_action :authorize_ssl_client_key, :only => [:update, :create]

    resource_description do
      api_version "v2"
    end

    def_param_group :product do
      param :description, String, :desc => N_("Product description")
      param :gpg_key_id, :number, :desc => N_("Identifier of the GPG key"), :allow_nil => true
      param :ssl_ca_cert_id, :number, :desc => N_("Idenifier of the SSL CA Cert"), :allow_nil => true
      param :ssl_client_cert_id, :number, :desc => N_("Identifier of the SSL Client Cert"), :allow_nil => true
      param :ssl_client_key_id, :number, :desc => N_("Identifier of the SSL Client Key"), :allow_nil => true
      param :sync_plan_id, :number, :desc => N_("Plan numeric identifier"), :allow_nil => true
    end

    api :GET, "/products", N_("List products")
    api :GET, "/subscriptions/:subscription_id/products", N_("List of subscription products in a subscription")
    api :GET, "/activation_keys/:activation_key_id/products", N_("List of subscription products in an activation key")
    api :GET, "/organizations/:organization_id/products", N_("List of products in an organization")
    api :GET, "/sync_plans/:sync_plan_id/products", N_("List of Products for sync plan")
    api :GET, "/organizations/:organization_id/sync_plans/:sync_plan_id/products", N_("List of Products for sync plan")
    param :organization_id, :number, :desc => N_("Filter products by organization"), :required => true
    param :subscription_id, :number, :desc => N_("Filter products by subscription")
    param :name, String, :desc => N_("Filter products by name")
    param :enabled, :bool, :desc => N_("Return enabled products only")
    param :custom, :bool, :desc => N_("Return custom products only")
    param :redhat_only, :bool, :desc => N_("Return Red Hat (non-custom) products only")
    param :include_available_content, :bool, :desc => N_("Whether to include available content attribute in results")
    param :sync_plan_id, :number, :desc => N_("Filter products by sync plan id")
    param :available_for, String, :desc => N_("Interpret specified object to return only Products that can be associated with specified object.  Only 'sync_plan' is supported."),
          :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Product)
    def index
      options = {:includes => [:sync_plan, :provider]}
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc, options))
    end

    def index_relation
      query = Product.readable.where(:organization_id => @organization.id)
      query = query.custom if ::Foreman::Cast.to_bool params[:custom]
      query = query.redhat if ::Foreman::Cast.to_bool params[:redhat_only]
      query = query.where(:name => params[:name]) if params[:name]
      query = query.enabled if ::Foreman::Cast.to_bool params[:enabled]
      query = query.where(:id => @activation_key.products) if @activation_key

      if params[:subscription_id]
        pool = Pool.with_identifier(params[:subscription_id])
        query = query.where(:id => pool.products) if pool
      end

      # filter by sync plan
      if (sync_plan_id = params[:sync_plan_id])
        query = if params[:available_for] == "sync_plan"
                  query.enabled.where("sync_plan_id != ? OR sync_plan_id IS NULL", sync_plan_id)
                else
                  query.where(:sync_plan_id => sync_plan_id)
                end
      end

      query
    end

    api :POST, "/products", N_("Create a product")
    param :organization_id, :number, N_("ID of the organization"), :required => true
    param_group :product
    param :name, String, :desc => N_("Product name"), :required => true
    param :label, String, :required => false
    def create
      params[:product][:label] = labelize_params(product_params) if product_params

      product = Product.new(product_params.to_h)

      sync_task(::Actions::Katello::Product::Create, product, @organization)
      respond_for_create(:resource => product)
    end

    api :GET, "/products/:id", N_("Show a product")
    param :organization_id, :number, :desc => N_("Organization ID")
    param :id, :number, :desc => N_("product numeric identifier"), :required => true
    def show
      find_product(:includes => [{:root_repositories => {:repositories => :environment}}])
      respond_for_show(:resource => @product)
    end

    api :PUT, "/products/:id", N_("Updates a product")
    param :id, :number, :desc => N_("product numeric identifier"), :required => true, :allow_nil => false
    param_group :product
    param :name, String, :desc => N_("Product name")
    def update
      sync_task(::Actions::Katello::Product::Update, @product, product_params.to_h)

      respond(:resource => @product.reload)
    end

    api :DELETE, "/products/:id", N_("Destroy a product")
    param :id, :number, :desc => N_("product numeric identifier")
    def destroy
      task = async_task(::Actions::Katello::Product::Destroy, @product)
      respond_for_async :resource => task
    end

    api :POST, "/products/:id/sync", N_("Sync all repositories for a product")
    param :id, :number, :required => true, :desc => "product ID"
    def sync
      syncable_repos = @product.library_repositories.has_url.syncable
      if syncable_repos.empty?
        msg = _("Unable to synchronize any repository. You either do not have the permission to"\
                " synchronize or the selected repositories do not have a feed url.")
        fail HttpErrors::UnprocessableEntity, msg
      end

      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Repository::Sync,
                        syncable_repos)

      respond_for_async(:resource => task)
    end

    protected

    def find_product(options = {})
      @product = Product.includes(options[:includes] || []).readable.find_by(:id => params[:id])
      throw_resource_not_found(name: 'product', id: params[:id]) if @product.nil?
    end

    def find_activation_key
      if params[:activation_key_id]
        @activation_key = ActivationKey.readable.find_by(:id => params[:activation_key_id])
        throw_resource_not_found(name: 'Activation Key', id: params[:activation_key_id]) if @activation_key.nil?
        @organization = @activation_key.organization
      end
    end

    def find_organization_from_product
      @organization = @product.organization
    end

    def authorize_gpg_key
      gpg_key_id = product_params[:gpg_key_id]
      if gpg_key_id
        gpg_key = ContentCredential.readable.where(:id => gpg_key_id, :organization_id => @organization).first
        throw_resource_not_found(name: 'gpg key', id: gpg_key_id) if gpg_key.nil?
      end
    end

    def authorize_ssl_ca_cert
      ssl_ca_cert_id = product_params[:ssl_ca_cert_id]
      if ssl_ca_cert_id
        ssl_ca_cert = ContentCredential.readable.where(:id => ssl_ca_cert_id, :organization_id => @organization).first
        throw_resource_not_found(name: 'ssl ca cert', id: ssl_ca_cert_id) if ssl_ca_cert.nil?
      end
    end

    def authorize_ssl_client_cert
      ssl_client_cert_id = product_params[:ssl_client_cert_id]
      if ssl_client_cert_id
        ssl_client_cert = ContentCredential.readable.where(:id => ssl_client_cert_id, :organization_id => @organization).first
        throw_resource_not_found(name: 'ssl client cert', id: ssl_client_cert_id) if ssl_client_cert.nil?
      end
    end

    def authorize_ssl_client_key
      ssl_client_key_id = product_params[:ssl_client_key_id]
      if ssl_client_key_id
        ssl_client_key = ContentCredential.readable.where(:id => ssl_client_key_id, :organization_id => @organization).first
        throw_resource_not_found(name: 'ssl client key', id: ssl_client_key_id) if ssl_client_key.nil?
      end
    end

    def product_params
      # only allow sync plan id to be updated if the product is a Red Hat product
      if @product&.redhat?
        params.require(:product).permit(:sync_plan_id)
      else
        params.require(:product).permit(:name, :label, :description, :provider_id, :gpg_key_id, :ssl_ca_cert_id, :ssl_client_cert_id, :ssl_client_key_id, :sync_plan_id)
      end
    end
  end
end
