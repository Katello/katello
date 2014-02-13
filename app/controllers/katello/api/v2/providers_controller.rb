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
class Api::V2::ProvidersController < Api::V2::ApiController

  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_provider, :only => [:show, :update, :destroy, :products, :import_products, :refresh_products,
                                          :import_manifest, :delete_manifest, :product_create, :refresh_manifest]
  before_filter :authorize

  def rules
    index_test  = lambda { @organization && Provider.any_readable?(@organization) }
    create_test = lambda { @organization.nil? ? true : Provider.creatable?(@organization) }
    read_test   = lambda { @provider.readable? }
    edit_test   = lambda { @provider.editable? }
    delete_test = lambda { @provider.deletable? }
    show_test   = lambda { @provider.readable? }

    {
      :index                    => index_test,
      :show                     => show_test,
      :create                   => create_test,
      :update                   => edit_test,
      :destroy                  => delete_test,
      :products                 => read_test,
      :import_manifest          => edit_test,
      :import_manifest_progress => read_test,
      :refresh_manifest         => edit_test,
      :delete_manifest          => edit_test,
      :import_products          => edit_test,
      :refresh_products         => edit_test,
      :product_create           => edit_test
    }
  end

  def_param_group :provider do
    param :name, String, :desc => "name of the provider"
    param :description, String, :desc => "description of the provider"
    param :provider_type, Provider::TYPES, :desc => "The type of the provider"
  end

  api :GET, "/providers", "List of all providers"
  api :GET, "/organizations/:organization_id/providers", "List of all providers for a given organization"
  param_group :search, Api::V2::ApiController
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :provider_type, String, "Filter providers by type ('Custom' or 'Red Hat')"
  def index
    options = sort_params
    options[:load_records?] = true

    ids = Provider.readable(@organization).where(:provider_type => params[:provider_type] || 'Custom').pluck(:id)
    options[:filters] = [{:terms => {:id => ids}}]

    respond(:collection => item_search(Provider, params, options))
  end

  api :GET, "/providers/:id", "Show a provider"
  param :id, :number, :desc => "ID of provider", :required => true
  def show
    respond
  end

  api :POST, "/providers", "Create a provider"
  param :organization_id, :identifier, :desc => "Organization identifier", :required => true
  param_group :provider
  def create
    provider = Provider.create!(provider_params) do |p|
      p.organization  = @organization
      p.provider_type = params[:provider]["provider_type"] if params[:provider].member? "provider_type"
      p.description = params[:provider]["description"] if params[:provider].member? "description"
      if params[:provider].member? "name"
        p.name = params[:provider]["name"]
        p.provider_type ||= Provider::CUSTOM
      else
        p.name = SecureRandom.uuid
        p.provider_type = Provider::ANONYMOUS
      end
    end
    respond(:resource => provider)
  end

  api :PUT, "/providers/:id", "Update a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true, :allow_nil => false
  param_group :provider
  def update
    @provider.update_attributes!(provider_params)

    respond
  end

  api :DELETE, "/providers/:id", "Destroy a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def destroy
    #
    # TODO: these should really be done as validations, but the orchestration engine currently converts them into OrchestrationExceptions
    # rubocop:disable LineLength
    fail HttpErrors::BadRequest, _("Provider cannot be deleted since one of its products or repositories has already been promoted. Using a changeset, please delete the repository from existing environments before deleting it.") if @provider.repositories.any? { |r| r.promoted? }

    @provider.destroy
    if @provider.destroyed?
      respond(:message => _("Deleted provider [ %s ]") % @provider.name)
    else
      fail HttpErrors::InternalError, _("Error while deleting provider [ %{name} ]: %{error}") % {:name => @provider.name, :error => @provider.errors.full_messages}
    end
  end

  api :GET, "/providers/:id/products", "List of provider's products"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param :include_marketing, :bool, :desc => "Include marketing products in results"
  def products
    @products = params[:include_marketing] ? @provider.products : @provider.products.engineering
    @products = @products.all_readable(@provider.organization).select("products.*, providers.name AS provider_name").joins(:provider)
    respond
  end

  api :POST, "/providers/:id/import_manifest", "Import manifest for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param :import, File, :desc => "Manifest file"
  param :force, :bool, :desc => "Force import"
  def import_manifest
    fail HttpErrors::BadRequest, _("Manifests cannot be imported for a custom provider.") unless @provider.redhat_provider?

    begin
      temp_file = File.new(File.join("#{Rails.root}/tmp", "import_#{SecureRandom.hex(10)}.zip"), 'wb+', 0600)
      temp_file.write File.open(File.expand_path(params[:import])).read
    ensure
      temp_file.close
    end

    @provider.import_manifest File.expand_path(temp_file.path), :force => params[:force],
                                                                :async => true,
                                                                :notify => false
    respond_for_async :resource => @provider.manifest_task
  end

  api :PUT, "/providers/:id/refresh_manifest", "Refresh previously imported manifest for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def refresh_manifest
    fail HttpErrors::BadRequest, _("Manifests cannot be imported for a custom provider.") unless @provider.redhat_provider?

    details  = @provider.organization.owner_details
    upstream = details['upstreamConsumer'].blank? ? {} : details['upstreamConsumer']

    @provider.refresh_manifest(upstream, :async => true, :notify => false)
    respond_for_async :resource => @provider.manifest_task, :status => :accepted
  end

  api :POST, "/providers/:id/delete_manifest", "Delete manifest from Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def delete_manifest
    fail HttpErrors::BadRequest, _("Manifests cannot be deleted for a custom provider.") unless @provider.redhat_provider?

    @provider.delete_manifest
    respond_for_status :message => _("Manifest deleted")
  end

  api :PUT, "/providers/:id/refresh_products", "Refresh products for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def refresh_products
    fail HttpErrors::BadRequest, _("Products cannot be refreshed for custom provider.") unless @provider.redhat_provider?

    @provider.refresh_products
    respond_for_status :message => _("Products refreshed from CDN")
  end

  api :POST, "/providers/:id/import_products", "Import products"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param :products, Array, :desc => "Array of products to import", :required => true
  def import_products
    results = params[:products].collect do |p|
      to_create = Product.new(p) do |product|
        product.provider     = @provider
        product.organization = @provider.organization
      end
      to_create.save!
    end
    respond_for_index :collection => results
  end

  api :POST, "/providers/:id/product_create", "Create a new product in custom provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  param_group :product, Api::V1::ProductsController, :as => :create
  param :product, Hash, :required => true do
    param :name, String, :desc => "Product name", :required => true
    param :label, String
  end
  def product_create
    fail HttpErrors::BadRequest, _("Products cannot be created for the Red Hat provider.") if @provider.redhat_provider?

    product_params = params[:product]

    if !product_params[:label].blank? &&
        (Product.all_in_org(@provider.organization).where('products.label = ?', product_params[:label]).count > 0)
      fail HttpErrors::BadRequest, _("Validation failed: Label has already been taken")
    end

    gpg  = GpgKey.readable(@provider.organization).find_by_name!(product_params[:gpg_key_name]) unless product_params[:gpg_key_name].blank?
    prod = @provider.add_custom_product(labelize_params(product_params), product_params[:name], product_params[:description], product_params[:url], gpg)
    respond_for_create :resource => prod
  end

  private

    def find_provider
      @provider = Provider.find(params[:id])
      @organization ||= @provider.organization
      fail HttpErrors::NotFound, _("Couldn't find provider '%s'") % params[:id] if @provider.nil?
    end

    def provider_params
      if params[:action] == "update" && @provider.redhat_provider?
        params.require(:provider).permit(:repository_url)
      elsif params[:action] != "create"
        params.require(:provider).permit(:name)
      end
    end
end
end
