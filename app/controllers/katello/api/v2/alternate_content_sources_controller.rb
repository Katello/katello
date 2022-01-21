module Katello
  class Api::V2::AlternateContentSourcesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch


    CONTENT_CREDENTIAL_GPG_KEY_TYPE = "gpg_key".freeze
    CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE = "ssl_ca_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE = "ssl_client_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE = "ssl_client_key".freeze

    before_action :find_authorized_katello_resource, :only => [:show]
    before_action :find_smart_proxies

    api :GET, "/alternate_content_sources", N_("List of alternate_content_sources")
    param :content_type, RepositoryTypeManager.defined_repository_types.keys, desc: N_("limit to only alternate content sources of this type")
    param :name, String, desc: N_("name of the alternate content source"), required: false
    param :label, String, desc: N_("label of the alternate content source"), required: false
    param :base_url, String, desc: N_('Base URL for finding alternate content')
    param :subpaths, Array, desc: N_('Path suffixes for finding alternate content')
    param :smart_proxy_ids, Array, desc: N_("ids of associated smart proxies"), required: false
    param :username, String, desc: N_("only show the repositories readable by this user with this username")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(AlternateContentSource)
    def index
      base_args = [index_relation.distinct, :name, :asc]

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

    def index_relation
      query = AlternateContentSource.readable
      query = with_type(params[:content_type]) if params[:content_type]
      query = query.where(name: params[:name]) if params[:name]
      query = query.where(label: params[:label]) if params[:label]
      query = query.where(base_url: params(:base_url)) if params[:base_url]
      query = query.where(subpaths: params(:subpaths)) if params[:subpaths]
      query = query.where(alternate_content_source_type: params(:alternate_content_source_type)) if params[:alternate_content_source_type]
      query = query.joins('inner join katello_smart_proxy_alternate_content_sources on katello_smart_proxy_alternate_content_sources.alternate_content_source_id = katello_alternate_content_sources.id').joins('inner join smart_proxies on katello_smart_proxy_alternate_content_sources.smart_proxy_id = smart_proxies.id').where('smart_proxies.id' => params[:smart_proxy_ids]) if params[:smart_proxy_ids]
      query
    end

    api :GET, "/alternate_content_sources/:id", N_("Show an alternate content source")
    param :id, :number, :required => true, :desc => N_("Alternate content source ID")
    def show
      respond_for_show(:resource => @alternate_content_source)
    end

    protected

    def find_smart_proxies
      if params[:smart_proxy_ids]
        @smart_proxies = ::SmartProxy.readable.where(id: params[:smart_proxy_ids])
        fail HttpErrors::NotFound, _("Couldn't find smart proxies with id '%s'") % params[:smart_proxy_ids].to_sentence if @smart_proxies.empty?
      end
    end
  end
end
