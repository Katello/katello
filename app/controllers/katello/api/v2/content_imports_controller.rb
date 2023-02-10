module Katello
  class Api::V2::ContentImportsController < Api::V2::ApiController
    before_action :find_organization, :only => [:version, :repository, :library]
    before_action :check_authorized, :only => [:version, :repository, :library]

    api :GET, "/content_imports", N_("List import histories")
    param :content_view_version_id, :number, :desc => N_("Content view version identifier"), :required => false
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => false
    param :id, :number, :desc => N_("Content view version import history identifier"), :required => false
    param :type, ::Katello::ContentViewVersionExportHistory::EXPORT_TYPES,
                                  :desc => N_("Import Types"),
                                  :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentViewVersionImportHistory)
    def index
      history = ContentViewVersionImportHistory.readable
      history = history.where(:id => params[:id]) unless params[:id].blank?
      history = history.where(:content_view_version_id => params[:content_view_version_id]) unless params[:content_view_version_id].blank?
      history = history.with_organization_id(params[:organization_id]) unless params[:organization_id].blank?
      history = history.with_content_view_id(params[:content_view_id]) unless params[:content_view_id].blank?
      history = history.where(:import_type => params[:type]) unless params[:type].blank?
      respond_with_template_collection("index", 'content_view_version_import_histories',
                                       :collection => scoped_search(history, 'id', 'asc', resource_class: ContentViewVersionImportHistory))
    end

    api :POST, "/content_imports/version", N_("Import a content view version")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :path, String, :desc => N_("Directory containing the exported Content View Version"), :required => true
    param :metadata, Hash, :desc => N_("Metadata taken from the upstream export history for this Content View Version"), :required => true
    def version
      task = async_task(::Actions::Katello::ContentViewVersion::Import, organization: @organization,
                                                  path: params[:path], metadata: metadata_params.to_h)
      respond_for_async :resource => task
    end

    api :POST, "/content_imports/library", N_("Import a content view version to the library")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :path, String, :desc => N_("Directory containing the exported Content View Version"), :required => true
    param :metadata, Hash, :desc => N_("Metadata taken from the upstream export history for this Content View Version"), :required => true
    def library
      task = async_task(::Actions::Katello::ContentViewVersion::ImportLibrary, @organization, path: params[:path], metadata: metadata_params.to_h)
      respond_for_async :resource => task
    end

    api :POST, "/content_imports/repository", N_("Import a repository")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :path, String, :desc => N_("Directory containing the exported Content View Version"), :required => true
    param :metadata, Hash, :desc => N_("Metadata taken from the upstream export history for this Content View Version"), :required => true
    def repository
      task = async_task(::Actions::Katello::ContentViewVersion::ImportRepository, @organization, path: params[:path], metadata: metadata_params.to_h)
      respond_for_async :resource => task
    end

    private

    def check_authorized
      fail HttpErrors::Forbidden, _("Action unauthorized to be performed in this organization.") unless @organization.can_import_content?
    end

    def metadata_params
      params.require(:metadata).permit(
        :organization,
        :repositories,
        :products,
        :toc,
        :incremental,
        :destination_server,
        :format,
        :base_path,
        gpg_keys: {},
        content_view: [:name, :label, :description, :generated_for],
        content_view_version: [:major, :minor, :description],
        from_content_view_version: [:major, :minor]
      ).tap do |nested|
        nested[:repositories] = params[:metadata].require(:repositories).permit!
        nested[:products] = params[:metadata].require(:products).permit!
      end
    end
  end
end
