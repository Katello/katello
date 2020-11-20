module Katello
  class Api::V2::ContentImportsController < Api::V2::ApiController
    before_action :find_publishable_content_view, :only => [:version]
    before_action :find_importable_organization, :only => [:library]
    before_action :find_default_content_view, :only => [:library]

    api :POST, "/content_imports/version", N_("Import a content view version")
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => true
    param :path, String, :desc => N_("Directory containing the exported Content View Version"), :required => true
    param :metadata, Hash, :desc => N_("Metadata taken from the upstream export history for this Content View Version"), :required => true
    def version
      if @view.default?
        fail HttpErrors::BadRequest, _("Cannot use this end point for importing to library. "\
                                       "If you intented to upload to library, use the library endpoint.")
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
