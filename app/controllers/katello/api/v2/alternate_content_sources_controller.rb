module Katello
  class Api::V2::AlternateContentSourcesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    acs_wrap_params = AlternateContentSource.attribute_names + [:smart_proxy_ids, :smart_proxy_names, :product_ids, :product_names]
    wrap_parameters :alternate_content_source, include: acs_wrap_params

    before_action :find_authorized_katello_resource, only: [:show, :update, :destroy, :refresh]
    before_action :find_smart_proxies, only: :create
    before_action :find_products, only: :create

    def_param_group :acs do
      param :name, String, desc: N_("Name of the alternate content source")
      param :description, String, desc: N_("Description for the alternate content source"), required: false
      param :base_url, String, desc: N_('Base URL for finding alternate content'), required: false
      param :subpaths, Array, desc: N_('Path suffixes for finding alternate content'), required: false
      param :smart_proxy_ids, Array, desc: N_("Ids of smart proxies to associate"), required: false
      param :smart_proxy_names, Array, desc: N_("Names of smart proxies to associate"), required: false
      param :upstream_username, String, desc: N_("Basic authentication username"), required: false
      param :upstream_password, String, desc: N_("Basic authentication password"), required: false
      param :ssl_ca_cert_id, :number, desc: N_("Identifier of the content credential containing the SSL CA Cert"), required: false
      param :ssl_client_cert_id, :number, desc: N_("Identifier of the content credential containing the SSL Client Cert"), required: false
      param :ssl_client_key_id, :number, desc: N_("Identifier of the content credential containing the SSL Client Key"), required: false
      param :http_proxy_id, :number, desc: N_("ID of a HTTP Proxy"), required: false
      param :verify_ssl, :bool, desc: N_("If SSL should be verified for the upstream URL"), required: false
      param :product_ids, Array, desc: N_("IDs of products to copy repository information from into a Simplified Alternate Content Source"), required: false
      param :product_names, Array, desc: N_("Names of products to copy repository information from into a Simplified Alternate Content Source"), required: false
    end

    api :GET, "/alternate_content_sources", N_("List of alternate_content_sources")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(AlternateContentSource)
    def index
      respond_to do |format|
        format.csv do
          options[:csv] = true
          alternate_content_sources = scoped_search(index_relation, :name, :asc)
          if @acs.custom?
            csv_response(alternate_content_sources,
                        [:id, :name, :description, :label, :base_url, :subpaths, :content_type, :alternate_content_source_type],
                        ['Id', 'Name', 'Description', 'label', 'Base URL', 'Subpaths', 'Content Type', 'Alternate Content Source Type'])
          elsif @acs.simplified?
            csv_response(alternate_content_sources,
                        [:id, :name, :description, :label, :content_type, :alternate_content_source_type, :products],
                        ['Id', 'Name', 'Description', 'label', 'Content Type', 'Alternate Content Source Type', 'Products'])
          end
        end
        format.any do
          alternate_content_sources = scoped_search(index_relation, :name, :asc)
          respond(collection: alternate_content_sources)
        end
      end
    end

    def index_relation
      AlternateContentSource.readable.distinct
    end

    api :GET, '/alternate_content_sources/:id', N_('Show an alternate content source')
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def show
      respond_for_show(:resource => @alternate_content_source)
    end

    api :POST, '/alternate_content_sources', N_('Create an ACS')
    param :content_type, RepositoryTypeManager.defined_repository_types.keys & AlternateContentSource::CONTENT_TYPES, desc: N_("The content type for the Alternate Content Source"), required: false
    param :alternate_content_source_type, AlternateContentSource::ACS_TYPES, desc: N_("The Alternate Content Source type")
    param_group :acs
    def create
      @alternate_content_source = ::Katello::AlternateContentSource.new(acs_params.except(:smart_proxy_ids, :smart_proxy_names, :product_ids, :product_names))
      sync_task(::Actions::Katello::AlternateContentSource::Create, @alternate_content_source, @smart_proxies, @products)
      @alternate_content_source.reload
      respond_for_create(resource: @alternate_content_source)
    end

    api :PUT, '/alternate_content_sources/:id', N_('Update an alternate content source')
    param_group :acs
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def update
      # If a user doesn't include smart proxies or products in the update call, don't accidentally remove all of them.
      if params[:smart_proxy_ids].nil? && params[:smart_proxy_names].nil?
        @smart_proxies = @alternate_content_source.smart_proxies
      elsif params[:smart_proxy_ids] == [] || params[:smart_proxy_names] == []
        @smart_proxies = []
      else
        find_smart_proxies
      end

      if params[:product_ids].nil? && params[:product_names].nil?
        @products = @alternate_content_source.products
      elsif params[:product_ids] == [] || params[:product_names] == []
        @products = []
      else
        find_products
      end
      sync_task(::Actions::Katello::AlternateContentSource::Update, @alternate_content_source, @smart_proxies, @products, acs_params.except(:smart_proxy_ids, :smart_proxy_names, :product_ids, :product_names))
      respond_for_show(:resource => @alternate_content_source)
    end

    api :DELETE, '/alternate_content_sources/:id', N_('Destroy an alternate content source')
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def destroy
      sync_task(::Actions::Katello::AlternateContentSource::Destroy, @alternate_content_source)
      respond_for_destroy
    end

    api :POST, '/alternate_content_sources/:id/refresh', N_('Refresh an alternate content source')
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def refresh
      task = async_task(::Actions::Katello::AlternateContentSource::Refresh, @alternate_content_source)
      respond_for_async :resource => task
    end

    protected

    def acs_params
      keys = [:name, :label, :description, {smart_proxy_ids: []}, {smart_proxy_names: []}, :content_type, :alternate_content_source_type]
      keys += [:base_url, {subpaths: []}, :upstream_username, :upstream_password, :ssl_ca_cert_id, :ssl_client_cert_id, :ssl_client_key_id, :http_proxy_id, :verify_ssl] if params[:action] == 'create' || @alternate_content_source&.custom?
      keys += [{product_ids: []}, {product_names: []}] if params[:action] == 'create' || @alternate_content_source&.simplified?
      params.require(:alternate_content_source).permit(*keys).to_h.with_indifferent_access
    end

    def find_smart_proxies
      if params[:smart_proxy_ids]
        @smart_proxies = ::SmartProxy.where(id: params[:smart_proxy_ids])
      elsif params[:smart_proxy_names]
        @smart_proxies = ::SmartProxy.where(name: params[:smart_proxy_names])
      end
      if params[:smart_proxy_ids] && @smart_proxies.length < params[:smart_proxy_ids].length
        missing_smart_proxies = params[:smart_proxy_ids] - @smart_proxies.pluck(:id)
        fail HttpErrors::NotFound, _("Couldn't find smart proxies with id '%s'") % missing_smart_proxies.to_sentence
      elsif params[:smart_proxy_names] && @smart_proxies.length < params[:smart_proxy_names].length
        missing_smart_proxies = params[:smart_proxy_names] - @smart_proxies.pluck(:name)
        fail HttpErrors::NotFound, _("Couldn't find smart proxies with name '%s'") % missing_smart_proxies.to_sentence
      end
    end

    def find_products
      if params[:product_ids]
        @products = ::Katello::Product.where(id: params[:product_ids])
      elsif params[:product_names]
        @products = ::SmartProxy.where(name: params[:product_names])
      else
        @products = nil
      end

      if params[:product_ids] && @products.length < params[:product_ids].length
        missing_products = params[:product_ids] - @products.pluck(:id)
        fail HttpErrors::NotFound, _("Couldn't find products with id '%s'") % missing_products.to_sentence
      elsif params[:product_names] && @products.length < params[:product_names].length
        missing_products = params[:product_names] - @products.pluck(:name)
        fail HttpErrors::NotFound, _("Couldn't find products with name '%s'") % missing_products.to_sentence
      end
    end
  end
end
