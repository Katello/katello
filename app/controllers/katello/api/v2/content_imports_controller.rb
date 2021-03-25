module Katello
  class Api::V2::ContentImportsController < Api::V2::ApiController
    before_action :find_publishable_content_view, :only => [:version]
    before_action :find_importable_organization, :only => [:library]
    before_action :find_default_content_view, :only => [:library]

    api :GET, "/content_imports", N_("List import histories")
    param :content_view_version_id, :number, :desc => N_("Content view version identifier"), :required => false
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => false
    param :id, :number, :desc => N_("Content view version import history identifier"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentViewVersionImportHistory)
    def index
      history = ContentViewVersionImportHistory.readable
      history = history.where(:id => params[:id]) unless params[:id].blank?
      history = history.where(:content_view_version_id => params[:content_view_version_id]) unless params[:content_view_version_id].blank?
      history = history.with_organization_id(params[:organization_id]) unless params[:organization_id].blank?
      history = history.with_content_view_id(params[:content_view_id]) unless params[:content_view_id].blank?
      respond_with_template_collection("index", 'content_view_version_import_histories',
                                       :collection => scoped_search(history, 'id', 'asc', resource_class: ContentViewVersionImportHistory))
    end

    api :POST, "/content_imports/version", N_("Import a content view version")
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => true
    param :path, String, :desc => N_("Directory containing the exported Content View Version"), :required => true
    param :metadata, Hash, :desc => N_("Metadata taken from the upstream export history for this Content View Version"), :required => true
    def version
      if @view.default?
        fail HttpErrors::BadRequest, _("Cannot use this endpoint for importing to library. "\
                                       "If you intended to upload to library, use /content_imports/library.")
      end

      task = async_task(::Actions::Katello::ContentViewVersion::Import, @view, path: params[:path], metadata: metadata_params.to_h)
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

    private

    def find_publishable_content_view
      @view = ContentView.publishable.find(params[:content_view_id])
      throw_resource_not_found(name: 'content_view', id: params[:content_view_id]) if @view.blank?
    end

    def find_default_content_view
      @view = @organization&.default_content_view
      throw_resource_not_found(name: 'organization', id: params[:organization_id]) if @view.blank?
    end

    def find_importable_organization
      find_organization
      throw_resource_not_found(name: 'organization', id: params[:organization_id]) unless @organization.can_import_library_content?
    end

    def metadata_params
      params.require(:metadata).permit(
        :organization,
        :content_view,
        :repository_mapping,
        :toc,
        content_view_version: [:major, :minor]
      ).tap do |nested|
        nested[:repository_mapping] = params[:metadata].require(:repository_mapping).permit!
      end
    end
  end
end
