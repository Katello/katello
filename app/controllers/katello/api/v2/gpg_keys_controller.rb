#
# Copyright 2013 Red Hat, Inc.
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

    before_filter :find_organization, :only => [:index, :create]
    before_filter :find_gpg_key, :only => [:show, :update, :destroy, :content]
    before_filter :authorize

    def_param_group :gpg_key do
      param :name, :identifier, :required => true, :desc => "identifier of the gpg key"
      param :content, String, :required => true, :desc => "public key block in DER encoding"
    end

    def rules
      index_test  = lambda { GpgKey.any_readable?(@organization) }
      create_test = lambda { GpgKey.createable?(@organization) }
      read_test   = lambda { @gpg_key.readable? }
      manage_test = lambda { @gpg_key.manageable? }

      {
        :index => index_test,
        :create => create_test,
        :show => read_test,
        :update  => manage_test,
        :destroy => manage_test,
        :content => manage_test
      }
    end

    api :GET, "/gpg_keys", "List gpg keys"
    param :organization_id, :identifier, :desc => "organization identifier"
    param_group :search, Api::V2::ApiController
    def index
      options = sort_params
      options[:load_records?] = true

      ids = GpgKey.readable(@organization).pluck(:id)

      options[:filters] = [
        {:terms => {:id => ids}}
      ]

      @search_service.model = GpgKey
      gpg_keys, total_count = @search_service.retrieve(params[:search], params[:offset], options)

      collection = {
        :results  => gpg_keys,
        :subtotal => total_count,
        :total    => @search_service.total_items
      }

      respond_for_index(:collection => collection)
    end

    api :POST, "/gpg_keys", "Create a gpg key"
    param :organization_id, :identifier, :desc => "organization identifier"
    param_group :gpg_key
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

    api :GET, "/gpg_keys/:id", "Show a gpg key"
    param :id, :identifier, :desc => "gpg key numeric identifier"
    def show
      respond_for_show(:resource => @gpg_key)
    end

    api :PUT, "/gpg_keys/:id", "Update a repository"
    param :id, :identifier, :required => true, :desc => "gpg key numeric identifier"
    param_group :gpg_key
    def update
      @gpg_key.update_attributes!(gpg_key_params)
      respond_for_show({:resource => @gpg_key})
    end

    api :DELETE, "/gpg_keys/:id", "Destroy a gpg key"
    param :id, :number, :desc => "gpg key numeric identifier"
    def destroy
      @gpg_key.destroy
      respond_for_destroy
    end

    api :POST, "/gpg_keys/:id/content"
    param :id, :number, :desc => "gpg key numeric identifier"
    param :content, File, :required => true, :desc => "file contents"
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
      params.slice(:name, :content)
    end

  end
end
