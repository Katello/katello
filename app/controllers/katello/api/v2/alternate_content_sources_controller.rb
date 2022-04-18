module Katello
  class Api::V2::AlternateContentSourcesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_authorized_katello_resource, :only => [:show, :update, :destroy]
    before_action :find_smart_proxies

    def_param_group :acs do
      param :name, String, desc: N_("Name of the alternate content source"), required: false
      param :description, String, desc: N_("Description for the alternate content source")
      param :base_url, String, desc: N_('Base URL for finding alternate content')
      param :subpaths, Array, desc: N_('Path suffixes for finding alternate content')
      param :smart_proxy_ids, Array, desc: N_("Ids of smart proxies to associate"), required: false
      param :content_type, RepositoryTypeManager.defined_repository_types.keys & AlternateContentSource::CONTENT_TYPES, desc: N_("The content type for the Alternate Content Source")
      param :alternate_content_source_type, AlternateContentSource::ACS_TYPES, desc: N_("The Alternate Content Source type")
      param :upstream_username, String, desc: N_("Basic authentication username"), required: false
      param :upstream_password, String, desc: N_("Basic authentication password"), required: false
      param :ssl_ca_cert_id, :number, desc: N_("Identifier of the content credential containing the SSL CA Cert"), required: false
      param :ssl_client_cert_id, :number, desc: N_("Identifier of the content credential containing the SSL Client Cert"), required: false
      param :ssl_client_key_id, :number, desc: N_("Identifier of the content credential containing the SSL Client Key"), required: false
      param :http_proxy_id, :number, desc: N_("ID of a HTTP Proxy"), required: false
      param :verify_ssl, :bool, desc: N_("If SSL should be verified for the upstream URL"), required: false
    end

    api :GET, "/alternate_content_sources", N_("List of alternate_content_sources")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(AlternateContentSource)
    def index
      base_args = [AlternateContentSource.readable.distinct, :name, :asc]

      respond_to do |format|
        format.csv do
          options[:csv] = true
          alternate_content_sources = scoped_search(*base_args)
          csv_response(alternate_content_sources,
                       [:id, :name, :description, :label, :base_url, :subpaths, :content_type, :alternate_content_source_type],
                       ['Id', 'Name', 'Description', 'label', 'Base URL', 'Subpaths', 'Content Type', 'Alternate Content Source Type'])
        end
        format.any do
          alternate_content_sources = scoped_search(*base_args)
          respond(collection: alternate_content_sources)
        end
      end
    end

    api :GET, '/alternate_content_sources/:id', N_('Show an alternate content source')
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def show
      respond_for_show(:resource => @alternate_content_source)
    end

    api :POST, '/alternate_content_sources', N_('Create an ACS')
    param_group :acs
    def create
      if params[:alternate_content_source_type] == 'custom'
        if params[:base_url] !~ /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
          fail HttpErrors::UnprocessableEntity, _('%s is not a valid path') % params[:base_url]
        end

        bad_subpaths = params[:subpaths]&.select { |subpath| subpath[0] == '/' || subpath[-1] != '/'}
        if bad_subpaths.present?
          fail HttpErrors::UnprocessableEntity, _('All subpaths must have a slash at the end and none at the front')
        end
      end
      @alternate_content_source = ::Katello::AlternateContentSource.new(acs_params)
      sync_task(::Actions::Katello::AlternateContentSource::Create, @alternate_content_source, @smart_proxies)
      respond_for_create(resource: @alternate_content_source.reload)
    end

    api :PUT, '/alternate_content_sources/:id', N_('Update an alternate content source')
    param_group :acs
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def update
      sync_task(::Actions::Katello::AlternateContentSource::Update, @alternate_content_source, @smart_proxies, acs_params)
      respond_for_show(:resource => @alternate_content_source)
    end

    api :DELETE, '/alternate_content_sources/:id', N_('Destroy an alternate content source')
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def destroy
      sync_task(::Actions::Katello::AlternateContentSource::Destroy, @alternate_content_source)
      respond_for_destroy
    end

    protected

    def acs_params
      keys = [:name, :label, :base_url, {subpaths: []}, {smart_proxy_ids: []}, :content_type, :alternate_content_source_type,
              :upstream_username, :upstream_password, :ssl_ca_cert_id, :ssl_client_cert_id, :ssl_client_key_id,
              :http_proxy_id, :verify_ssl]
      params.require(:alternate_content_source).permit(*keys).to_h.with_indifferent_access
    end

    def find_smart_proxies
      if params[:smart_proxy_ids]
        @smart_proxies = ::SmartProxy.where(id: params[:smart_proxy_ids])
        fail HttpErrors::NotFound, _("Couldn't find smart proxies with id '%s'") % params[:smart_proxy_ids].to_sentence if @smart_proxies.empty?
      end
    end
  end
end
