#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class Api::V2::ContentUploadsController < Api::V2::ApiController

  before_filter :find_repository

  api :POST, "/repositories/:repo_id/content_uploads", N_("Create an upload request")
  param :repo_id, :identifier, :required => true, :desc => N_("repository id")
  def create
    respond :resource => pulp_content.create_upload_request
  end

  api :PUT, "/repositories/:repo_id/content_uploads/:id/upload_bits", N_("Upload bits")
  param :repo_id, :identifier, :required => true, :desc => N_("repository id")
  param :id, :identifier, :required => true, :desc => N_("upload request id")
  param :offset, :number, :required => true, :desc => N_("the offset at which Pulp will store the file contents")
  param :content, File, :required => true, :desc => N_("file contents")
  def upload_bits
    pulp_content.upload_bits(params[:id], params[:offset], params[:content])
    render :nothing => true
  end

  api :DELETE, "/repositories/:repo_id/content_uploads/:id", N_("Delete an upload request")
  param :repo_id, :identifier, :required => true, :desc => N_("repository id")
  param :id, :identifier, :required => true, :desc => N_("upload request id")
  def destroy
    pulp_content.delete_upload_request(params[:id])
    render :nothing => true
  end

  api :POST, "/repositories/:repo_id/content_uploads/import_into_repo", N_("Import into a repository")
  param :repo_id, :identifier, :required => true, :desc => N_("repository id")
  param :uploads, Array, :required => true, :desc => N_("array of uploads to import")
  def import_into_repo
    params[:uploads].each do |upload|
      pulp_content.import_into_repo(@repo.pulp_id, @repo.unit_type_id,
        upload[:id], upload[:unit_key], {:unit_metadata => upload[:metadata]})
    end

    unit_keys = params[:uploads].map { |upload| upload[:unit_key] }
    @repo.trigger_contents_changed(:wait => false, :index_units => unit_keys, :reindex => false)
    render :nothing => true
  end

  api :POST, "/repositories/:id/content_uploads/file", N_("Upload content into the repository")
  param :id, :identifier, :required => true
  param :content, File, :required => true, :desc => N_("file contents")
  def upload_file
    filepaths = params.try(:[], :content).try(:map, &:path)

    if !filepaths.blank?
      @repo.upload_content(filepaths)
      render :json => {:status => "success"}
    else
      fail HttpErrors::BadRequest, _("No file uploaded")
    end

  rescue Katello::Errors::InvalidPuppetModuleError => error
    respond_for_exception(
      error,
      :status => :unprocessable_entity,
      :text => error.message,
      :errors => [error.message],
      :with_logging => true
    )
  end

  private

  def pulp_content
    Katello.pulp_server.resources.content
  end

  def find_repository
    @repo = Repository.find(params[:repository_id])
  end

end
end
