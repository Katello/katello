module Katello
  class Api::V2::ContentUploadsController < Api::V2::ApiController
    before_action :find_repository
    skip_before_action :check_media_type, :only => [:update]
    # https://github.com/rails/rails/issues/42278#issuecomment-918079123
    skip_parameter_encoding :update

    include ::Foreman::Controller::FilterParameters
    filter_parameters :content

    api :POST, "/repositories/:repository_id/content_uploads", N_("Create an upload request")
    param :repository_id, :number, :required => true, :desc => N_("repository id")
    param :size, :number, :required => true, :desc => N_("Size of file to upload")
    param :checksum, String, :required => false, :desc => N_("Checksum of file to upload")
    param :content_type, RepositoryTypeManager.uploadable_content_types(false).map(&:label), :required => false, :desc => N_("content type ('deb', 'file', 'ostree_ref', 'rpm', 'srpm')")
    def create
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload Ansible collections.") if @repository.ansible_collection?
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload container content via Hammer/API. Use podman push instead.") if @repository.docker?
      content_type = params[:content_type] || ::Katello::RepositoryTypeManager.find(@repository.content_type)&.default_managed_content_type&.label
      RepositoryTypeManager.check_content_matches_repo_type!(@repository, content_type)
      if ::Katello::RepositoryTypeManager.generic_content_type?(content_type)
        unit_type_id = content_type
      else
        unit_type_id = SmartProxy.pulp_primary.content_service(content_type).content_type
      end
      render :json => @repository.backend_content_service(::SmartProxy.pulp_primary).create_upload(params[:size], params[:checksum], unit_type_id, @repository)
    end

    api :PUT, "/repositories/:repository_id/content_uploads/:id", N_("Upload a chunk of the file's content")
    param :repository_id, :number, :required => true, :desc => N_("Repository id")
    param :id, String, :required => true, :desc => N_("Upload request id")
    param :size, :number, :required => true, :desc => N_("Size of file to upload")
    param :offset, :number, :required => true, :desc => N_("The offset in the file where the content starts")
    param :content, File, :required => true, :desc => N_("The actual file contents")
    def update
      @repository.backend_content_service(::SmartProxy.pulp_primary)
        .upload_chunk(params[:id], params[:offset], params[:content], params[:size])
      head :no_content
    end

    api :DELETE, "/repositories/:repository_id/content_uploads/:id", N_("Delete an upload request")
    param :repository_id, :number, :required => true, :desc => N_("Repository id")
    param :id, String, :required => true, :desc => N_("Upload request id")
    def destroy
      @repository.backend_content_service(::SmartProxy.pulp_primary).delete_upload(params[:id])
      head :no_content
    end

    private

    def find_repository
      @repository = Repository.find(params[:repository_id])
    end
  end
end
