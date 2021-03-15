module Katello
  class Api::V2::ContentExportsController < Api::V2::ApiController
    before_action :fail_if_not_pulp3, :only => [:version, :library]
    before_action :find_exportable_organization, :only => [:library]
    before_action :find_exportable_content_view_version, :only => [:version]

    api :GET, "/content_exports", N_("List export histories")
    param :content_view_version_id, :number, :desc => N_("Content view version identifier"), :required => false
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => false
    param :id, :number, :desc => N_("Content view version export history identifier"), :required => false
    param :type, ::Katello::ContentViewVersionExportHistory::EXPORT_TYPES,
                                  :desc => N_("Export Types"),
                                  :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentViewVersionExportHistory)
    def index
      history = ContentViewVersionExportHistory.readable
      history = history.where(:id => params[:id]) unless params[:id].blank?
      history = history.where(:content_view_version_id => params[:content_view_version_id]) unless params[:content_view_version_id].blank?
      history = history.where(:destination_server => params[:destination_server]) unless params[:destination_server].blank?
      history = history.where(:export_type => params[:type]) unless params[:type].blank?
      history = history.with_organization_id(params[:organization_id]) unless params[:organization_id].blank?
      history = history.with_content_view_id(params[:content_view_id]) unless params[:content_view_id].blank?
      respond_with_template_collection("index", 'content_view_version_export_histories',
                                       :collection => scoped_search(history, 'id', 'asc', resource_class: ContentViewVersionExportHistory))
    end

    api :GET, "/content_exports/api_status", N_("true if the export api is pulp3 ready and usable. This API is intended for use by hammer-cli only.")
    def api_status
      ::Foreman::Deprecation.api_deprecation_warning("/content_exports/api_status is being deprecated and will be removed in Katello 4.1.")
      render json: { api_usable: SmartProxy.pulp_primary.pulp3_repository_type_support?(Katello::Repository::YUM_TYPE) }, status: :ok
    end

    api :POST, "/content_exports/version", N_("Performs a full-export of a content view version.")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_mb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in megabytes."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this version"\
                                                         " are unexportable. False by default."), :required => false
    def version
      tasks = async_task(::Actions::Pulp3::Orchestration::ContentViewVersion::Export,
                          content_view_version: @version,
                          destination_server: params[:destination_server],
                          chunk_size: params[:chunk_size_mb],
                          fail_on_missing_content: ::Foreman::Cast.to_bool(params[:fail_on_missing_content]))
      respond_for_async :resource => tasks
    end

    api :POST, "/content_exports/library", N_("Performs a full-export of the repositories in library.")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_mb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in megabytes."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this organization"\
                                                         " are unexportable. False by default."), :required => false
    def library
      tasks = async_task(::Actions::Pulp3::Orchestration::ContentViewVersion::ExportLibrary,
                          @organization,
                          destination_server: params[:destination_server],
                          chunk_size: params[:chunk_size_mb],
                          fail_on_missing_content: ::Foreman::Cast.to_bool(params[:fail_on_missing_content]))
      respond_for_async :resource => tasks
    end

    private

    def find_exportable_content_view_version
      @version = ContentViewVersion.exportable.find_by_id(params[:id])
      throw_resource_not_found(name: 'content view version', id: params[:id]) if @version.blank?
    end

    def find_exportable_organization
      find_organization
      unless @organization.can_export_library_content?
        throw_resource_not_found(name: 'organization', id: params[:organization_id])
      end
    end

    def fail_if_not_pulp3
      unless SmartProxy.pulp_primary.pulp3_repository_type_support?(Katello::Repository::YUM_TYPE)
        fail HttpErrors::BadRequest, _("Invalid usage for Pulp 2 repositories. Use export for Yum repositories")
      end
    end
  end
end
