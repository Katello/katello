module Katello
  class Api::V2::ContentUploadsController < Api::V2::ApiController
    before_action :find_repository
    skip_before_action :check_content_type, :only => [:update]

    include ::Foreman::Controller::FilterParameters
    filter_parameters :content

    api :POST, "/repositories/:repository_id/content_uploads", N_("Create an upload request")
    param :repository_id, :number, :required => true, :desc => N_("repository id")
    def create
      render :json => @repository.backend_content_service(::SmartProxy.pulp_master).create_upload
    end

    api :PUT, "/repositories/:repository_id/content_uploads/:id", N_("Upload a chunk of the file's content")
    param :repository_id, :number, :required => true, :desc => N_("Repository id")
    param :id, :number, :required => true, :desc => N_("Upload request id")
    param :offset, :number, :required => true, :desc => N_("The offset in the file where the content starts")
    param :content, File, :required => true, :desc => N_("The actual file contents")
    def update
      @repository.backend_content_service(::SmartProxy.pulp_master)
        .upload_chunk(params[:id], params[:offset], params[:content])
      head :no_content
    end

    api :DELETE, "/repositories/:repository_id/content_uploads/:id", N_("Delete an upload request")
    param :repository_id, :number, :required => true, :desc => N_("Repository id")
    param :id, :number, :required => true, :desc => N_("Upload request id")
    def destroy
      @repository.backend_content_service(::SmartProxy.pulp_master).delete_upload(params[:id])
      head :no_content
    end

    private

    def find_repository
      @repository = Repository.find(params[:repository_id])
    end
  end
end
