module Katello
  class Api::V2::ContentExportsController < Api::V2::ApiController
    include Katello::Concerns::Api::V2::ExportsController

    before_action :find_exportable_organization, :only => [:library]
    before_action :find_exportable_content_view_version, :only => [:version]
    before_action :find_exportable_repository, :only => [:repository]

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

    api :POST, "/content_exports/version", N_("Performs a full-export of a content view version.")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    export_version_description
    def version
      export_content_view_version
    end

    api :POST, "/content_exports/library", N_("Performs a full-export of the repositories in library.")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    export_library_description
    def library
      export_library
    end

    api :POST, "/content_exports/repository", N_("Performs a full-export of the repository in library.")
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    export_repository_description
    def repository
      export_repository
    end
  end
end
