module Katello
  class Api::V2::ContentExportsController < Api::V2::ApiController
    before_action :find_exportable_content_view_version, :only => [:version]

    api :GET, "/content_exports", N_("List export histories")
    param :content_view_version_id, :number, :desc => N_("Content view version identifier"), :required => false
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => false
    param :id, :number, :desc => N_("Content view version export history identifier"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentViewVersionExportHistory)
    def index
      history = ContentViewVersionExportHistory.readable
      history = history.where(:id => params[:id]) unless params[:id].blank?
      history = history.where(:content_view_version_id => params[:content_view_version_id]) unless params[:content_view_version_id].blank?
      history = history.where(:destination_server => params[:destination_server]) unless params[:destination_server].blank?
      history = history.with_organization_id(params[:organization_id]) unless params[:organization_id].blank?
      history = history.with_content_view_id(params[:content_view_id]) unless params[:content_view_id].blank?
      respond_with_template_collection("index", 'content_view_version_export_histories',
                                       :collection => scoped_search(history, 'id', 'asc', resource_class: ContentViewVersionExportHistory))
    end

    api :GET, "/content_exports/api_status", N_("true if the export api is pulp3 ready and usable. This API is intended for use by hammer-cli only.")
    def api_status
      ::Foreman::Deprecation.api_deprecation_warning("/content_exports/api_status is being deprecated and will be removed in a future version of Katello.")
      render json: { api_usable: SmartProxy.pulp_primary.pulp3_repository_type_support?(Katello::Repository::YUM_TYPE) }, status: :ok
    end

    api :POST, "/content_exports/version", N_("Performs a full-export of a content view version.  Relevant only for Pulp 3 repositories")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name, required for Pulp3"), :required => true
    param :chunk_size_mb, :number, :desc => N_("Chunk export-tarfile into pieces of chunk_size mega bytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export."), :required => false
    def version
      fail HttpErrors::BadRequest, _("Invalid usage for Pulp 2 repositories. Use export for Yum repositories") unless SmartProxy.pulp_primary.pulp3_repository_type_support?(Katello::Repository::YUM_TYPE)

      if params[:destination_server].blank?
        fail HttpErrors::BadRequest, _("Destination Server Name required for Pulp3 repositories")
      end

      history = ::Katello::ContentViewVersionExportHistory.find(params[:from_history_id]) unless params[:from_history_id].blank?

      tasks = async_task(::Actions::Pulp3::Orchestration::ContentViewVersion::Export, @version, destination_server: params[:destination_server],
                                                                                         chunk_size: params[:chunk_size_mb],
                                                                                         from_history: history)

      respond_for_async :resource => tasks
    end

    private

    def find_exportable_content_view_version
      @version = ContentViewVersion.exportable.find_by_id(params[:id])
      throw_resource_not_found(name: 'content view version', id: params[:id]) if @version.blank?
    end
  end
end
