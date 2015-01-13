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
  class Api::V2::GpgKeysController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_filter :authorize
    before_filter :find_organization, :only => [:create, :index, :auto_complete_search]
    before_filter :find_gpg_key, :only => [:show, :update, :destroy, :content]
    skip_before_filter :check_content_type, :only => [:create]

    def_param_group :gpg_key do
      param :name, :identifier, :action_aware => true, :required => true, :desc => N_("identifier of the gpg key")
      param :content, String, :action_aware => true, :required => true, :desc => N_("public key block in DER encoding")
    end

    resource_description do
      description <<-DESC
        # Description
        Documents the calls for the list, read, create, update and delete operations for GPG keys
      DESC
      api_version "v2"
    end

    api :GET, "/gpg_keys", N_("List gpg keys")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name of the GPG key"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :desc))
    end

    def index_relation
      query = GpgKey.readable.where(:organization_id => @organization.id)
      query = query.where(:name => params[:name]) if params[:name]
      query
    end

    api :POST, "/gpg_keys", N_("Create a gpg key")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param_group :gpg_key, :as => :create
    def create
      filepath = params.try(:[], :file_path).try(:path)

      content = nil
      if filepath
        content = File.open(filepath, "rb") { |file| file.read }
      else
        content = params[:content]
      end

      gpg_key = @organization.gpg_keys.create!(gpg_key_params.merge(:content => content))
      respond_for_show(:resource => gpg_key)
    end

    api :GET, "/gpg_keys/:id", N_("Show a gpg key")
    param :id, :identifier, :desc => N_("gpg key numeric identifier"), :required => true
    def show
      respond_for_show(:resource => @gpg_key)
    end

    api :PUT, "/gpg_keys/:id", N_("Update a repository")
    param :id, :identifier, :desc => N_("gpg key numeric identifier"), :required => true
    param_group :gpg_key
    def update
      @gpg_key.update_attributes!(gpg_key_params)
      respond_for_show(:resource => @gpg_key)
    end

    api :DELETE, "/gpg_keys/:id", N_("Destroy a gpg key")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    def destroy
      @gpg_key.destroy
      respond_for_destroy
    end

    api :POST, "/gpg_keys/:id/content", N_("Upload gpg key contents")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    param :content, File, :required => true, :desc => N_("file contents"), :required => true
    def content
      filepath = params.try(:[], :content).try(:path)

      if filepath
        content = File.open(filepath, "rb") { |file| file.read }
        @gpg_key.update_attributes!(:content => content)
        render :json => {:status => "success"}
      else
        fail HttpErrors::BadRequest, _("No file uploaded")
      end
    end

    protected

    def find_gpg_key
      @gpg_key = GpgKey.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise HttpErrors::NotFound, _("Couldn't find GPG key '%s'") % params[:id]
    end

    def gpg_key_params
      params.permit(:name, :content)
    end
  end
end
