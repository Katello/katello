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

class Api::ProvidersController < Api::ApiController

  resource_description do
    description "Custom Content Repositories and Red Hat repositories management."
  end

  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_provider, :only => [:show, :update, :destroy, :products, :import_products, :discovery,
                                          :refresh_products, :import_manifest, :delete_manifest, :product_create,
                                          :import_manifest_progress]
  before_filter :authorize

  def rules
    index_test = lambda{Provider.any_readable?(@organization)}
    create_test = lambda{Provider.creatable?(@organization)}
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    delete_test = lambda{@provider.deletable?}
    {
      :index => index_test,
      :show => index_test,

      :create => create_test,
      :update => edit_test,
      :destroy => delete_test,
      :discovery => edit_test,
      :products => read_test,
      :import_manifest => edit_test,
      :import_manifest_progress => read_test,
      :delete_manifest => edit_test,
      :import_products => edit_test,
      :refresh_products => edit_test,
      :product_create => edit_test,
    }
  end

  def param_rules
    {
      :create => {:provider  => [:name, :description, :provider_type, :repository_url]},
      :update => {:provider  => [:name, :description, :repository_url]}
    }
  end

  def_param_group :provider do
    param :provider, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "Provider name", :required => true
      param :description, String, :desc => "Provider description"
      param :repository_url, String, :desc => "Repository URL"
    end
  end

  api :GET, "/organizations/:organization_id/providers", "List providers"
  param :organization_id, :identifier, :desc => "Organization identifier", :required => true
  param :name, String, :desc => "Filter providers by name"
  def index
    query_params.delete(:organization_id)
    render :json => (Provider.readable(@organization).where query_params).to_json
  end

  api :GET, "/providers/:id", "Show a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def show
    render :json => @provider.to_json
  end

  api :POST, "/providers", "Create a provider"
  param :organization_id, :identifier, :desc => "Organization identifier", :required => true
  param_group :provider
  param :provider, Hash do
    param :provider_type, ["Red Hat", "Custom"], :required => true
  end
  def create
    provider = Provider.create!(params[:provider]) do |p|
      p.organization = @organization
    end
    render :json => provider.to_json and return
  end

  api :PUT, "/providers/:id", "Update a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param_group :provider
  def update
    @provider.update_attributes!(params[:provider])
    render :json => @provider.to_json and return
  end

  api :DELETE, "/providers/:id", "Destroy a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def destroy
    #
    # TODO: these should really be done as validations, but the orchestration engine currently converts them into OrchestrationExceptions
    #
    raise HttpErrors::BadRequest, _("Provider cannot be deleted since one of its products or repositories has already been promoted. Using a changeset, please delete the repository from existing environments before deleting it.") if @provider.repositories.any? {|r| r.promoted? }

    @provider.destroy
    if @provider.destroyed?
      render :text => _("Deleted provider [ %s ]") % @provider.name , :status => 200
    else
      # TOOO: should probably be more specific?
      raise HttpErrors::InternalError, _("Error while deleting provider [ %{name} ]: %{error}") % {:name => @provider.name, :error => @provider.errors.full_messages}
    end
  end

  api :GET, "/providers/:id/products", "List of provider's products"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def products
    render :json => @provider.products.all_readable(@provider.organization).select("products.*, providers.name AS provider_name").joins(:provider).to_json
  end

  api :POST, "/providers/:id/discovery", "Discover repository urls with metadata and find candidate repos. Supports http, https and file based urls. Async task, returns the delayed job."
  param :url, String, :required => true, :desc => "remote url to perform discovery"
  def discovery
    @provider.discovery_url = params[:url]
    @provider.save
    @provider.discover_repos
    task = @provider.discovery_task
    render :json => task
  end

  api :POST, "/providers/:id/import_manifest", "Import manifest for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param :import, File, :desc => "Manifest file"
  param :force, :bool, :desc => "Force import"
  def import_manifest
    if @provider.yum_repo?
      raise HttpErrors::BadRequest, _("It is not allowed to import manifest for a custom provider.")
    end

    begin
      temp_file = File.new(File.join("#{Rails.root}/tmp", "import_#{SecureRandom.hex(10)}.zip"), 'wb+', 0600)
      temp_file.write params[:import].read
    ensure
      temp_file.close
    end

    @provider.import_manifest File.expand_path(temp_file.path), :force => params[:force],
                              :async => true, :notify => false
    render :json => @provider.manifest_task, :status => 200
  end

  api :POST, "/providers/:id/delete_manifest", "Delete manifest from Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def delete_manifest
    if @provider.yum_repo?
      raise HttpErrors::BadRequest, _("It is not allowed to delete manifest for a custom provider.")
    end

    @provider.delete_manifest
    render :text => "Manifest deleted", :status => 200
  end

  api :POST, "/providers/:id/refresh_products", "Refresh products for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def refresh_products
    raise HttpErrors::BadRequest, _("It is not allowed to refresh products for custom provider.") unless @provider.redhat_provider?

    @provider.refresh_products
    render :text => _("Products refreshed from CDN"), :status => 200
  end

  api :POST, "/providers/:id/import_products", "Import products"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param :products, Array, :desc => "Array of products to import", :required => true
  def import_products
    results = params[:products].collect do |p|
      to_create = Product.new(p) do |product|
        product.provider = @provider
        product.organization = @provider.organization
      end
      to_create.save!
    end
    render :json => results.to_json
  end

  api :POST, "/providers/:id/product_create", "Create a new product in custom provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param_group :product, Api::ProductsController, :as => :create
  param :product, Hash, :required => true do
    param :name, String, :desc => "Product name", :required => true
    param :label, String
  end
  def product_create
    raise HttpErrors::BadRequest, _("It is not allowed to create products in Red Hat provider.") if @provider.redhat_provider?

    product_params = params[:product]

    # Ideally, the following should be a model validation; however, we want a different behavior
    # in API vs UI. In the API, if the user gives a label that is already in use, we want to treat
    # it as an immediate error; however, in the UI we'll override the label value (since the one provided
    # in the ui could be the result of an initial query to retrieve a default label)
    if !product_params[:label].blank? &&
       (Product.all_in_org(@provider.organization).where('products.label = ?', product_params[:label]).count > 0)
      raise HttpErrors::BadRequest, _("Validation failed: Label has already been taken")
    end

    gpg  = GpgKey.readable(@provider.organization).find_by_name!(product_params[:gpg_key_name]) unless product_params[:gpg_key_name].blank?
    prod = @provider.add_custom_product(labelize_params(product_params), product_params[:name], product_params[:description], product_params[:url], gpg)
    render :json => prod
  end

  private

  def find_provider
    @provider = Provider.find(params[:id])
    @organization ||= @provider.organization
    raise HttpErrors::NotFound, _("Couldn't find provider '%s'") % params[:id] if @provider.nil?
  end

end
