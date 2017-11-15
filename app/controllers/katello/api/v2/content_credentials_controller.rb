module Katello
  class Api::V2::ContentCredentialsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :authorize
    before_action :find_organization, :only => [:create, :index, :auto_complete_search]
    before_action :find_content_credential, :only => [:show, :update, :destroy, :content, :set_content]
    skip_before_action :check_content_type, :only => [:create, :content, :set_content]

    def resource_class
      Katello::GpgKey
    end

    def_param_group :content_credential do
      param :name, :identifier, :action_aware => true, :required => true, :desc => N_("identifier of the content credential")
      param :content_type, String, :action_aware => true, :required => true, :desc => N_("type of content")
      param :content, String, :action_aware => true, :required => true, :desc => N_("public key block in DER encoding / certificate content")
    end

    resource_description do
      description <<-DESC
        # Description

        Content Credentials are used to store credentials like GPG Keys and Certificates for the authentication
        to Products / Repositories.
      DESC
      api_version "v2"
    end

    api :GET, "/content_credentials", N_("List content credentials")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name of the Content Credential"), :required => false
    param :content_type, String, :desc => N_("type of content"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :asc))
    end

    def index_relation
      query = GpgKey.readable.where(:organization_id => @organization.id)
      query = query.where(:name => params[:name]) if params[:name]
      query
    end

    api :POST, "/content_credentials", N_("Create a content credential")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param_group :content_credential, :as => :create
    def create
      filepath = params.try(:[], :file_path).try(:path)

      content = nil
      if filepath
        content = File.open(filepath, "rb") { |file| file.read }
      else
        content = params[:content]
      end

      content_credential = @organization.gpg_keys.create!(content_credential_params.merge(:content => content))
      respond_for_show(:resource => content_credential)
    end

    api :GET, "/content_credentials/:id", N_("Show a content credential")
    param :id, :number, :desc => N_("content credential numeric identifier"), :required => true
    def show
      respond_for_show(:resource => @content_credential)
    end

    api :PUT, "/content_credentials/:id", N_("Update a content credential")
    param :id, :number, :desc => N_("content credential numeric identifier"), :required => true
    param_group :content_credential
    def update
      @content_credential.update_attributes!(content_credential_params)
      respond_for_show(:resource => @content_credential)
    end

    api :DELETE, "/content_credentials/:id", N_("Destroy a content credential")
    param :id, :number, :desc => N_("content credential numeric identifier"), :required => true
    def destroy
      @content_credential.destroy
      respond_for_destroy
    end

    api :GET, "/content_credentials/:id/content", N_("Return the content of a content credential, used directly by yum")
    param :id, :number, :required => true
    def content
      render(:plain => @content_credential.content, :layout => false)
    end

    api :POST, "/content_credentials/:id/content", N_("Upload content credential contents")
    param :id, :number, :desc => N_("content credential numeric identifier"), :required => true
    param :content, File, :desc => N_("file contents"), :required => true
    def set_content
      filepath = params.try(:[], :content).try(:path)

      if filepath
        content = File.open(filepath, "rb") { |file| file.read }
        @content_credential.update_attributes!(:content => content)
        render :json => {:status => "success"}
      else
        fail HttpErrors::BadRequest, _("No file uploaded")
      end
    end

    protected

    def find_content_credential
      @content_credential = GpgKey.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise HttpErrors::NotFound, _("Couldn't find Content Credential '%s'") % params[:id]
    end

    def content_credential_params
      params.permit(:name, :content_type, :content)
    end
  end
end
