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
    skip_before_filter :check_content_type, :only => [:update]

    include Foreman::Controller::FilterParameters
    filter_parameters :content

    api :POST, "/repositories/:repository_id/content_uploads", N_("Create an upload request")
    param :repository_id, :identifier, :required => true, :desc => N_("repository id")
    def create
      render :json => pulp_content.create_upload_request
    end

    api :PUT, "/repositories/:repository_id/content_uploads/:id", N_("Upload a chunk of the file's content")
    param :repository_id, :identifier, :required => true, :desc => N_("Repository id")
    param :id, :identifier, :required => true, :desc => N_("Upload request id")
    param :offset, :number, :required => true, :desc => N_("The offset in the file where the content starts")
    param :content, File, :required => true, :desc => N_("The actual file contents")
    def update
      pulp_content.upload_bits(params[:id], params[:offset], params[:content])
      render :nothing => true
    end

    api :DELETE, "/repositories/:repository_id/content_uploads/:id", N_("Delete an upload request")
    param :repository_id, :identifier, :required => true, :desc => N_("Repository id")
    param :id, :identifier, :required => true, :desc => N_("Upload request id")
    def destroy
      pulp_content.delete_upload_request(params[:id])
      render :nothing => true
    end

    private

    def pulp_content
      Katello.pulp_server.resources.content
    end

    def find_repository
      @repository = Repository.find(params[:repository_id])
    end
  end
end
