module Katello
  class Api::V2::ContentCredentialsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_organization, :only => [:create, :index, :auto_complete_search]
    before_action :find_authorized_katello_resource, :only => [:show, :update, :destroy, :content, :set_content]
    skip_before_action :check_media_type, :only => [:create, :content, :set_content]

    def resource_class
      Katello::GpgKey
    end

    def_param_group :content_credential do
      param :name, :identifier, :action_aware => true, :required => true, :desc => N_('Name of the Content Credential')
      param :content_type, String, :action_aware => true, :required => true, :desc => N_('Type of content: "cert", "gpg_key"')
      param :content, String, :action_aware => true, :required => true, :desc => N_('Public key block in DER encoding or certificate content')
    end

    resource_description do
      description <<-DESC
        # Description

        Content Credentials are used to store credentials like GPG Keys and Certificates for the authentication
        to Products / Repositories.
      DESC
      api_version 'v2'
    end

    api :GET, "/content_credentials", N_('List Content Credentials')
    param :organization_id, :number, :desc => N_('Organization identifier'), :required => true
    param :name, String, :desc => N_('Name of the Content Credential'), :required => false
    param :content_type, String, :desc => N_('Type of content'), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc))
    end

    def index_relation
      query = GpgKey.readable.where(:organization_id => @organization.id)
      query = query.where(:name => params[:name]) if params[:name]
      query = query.where(:content_type => params[:content_type]) if params[:content_type]
      query
    end

    api :POST, "/content_credentials", N_('Create a Content Credential')
    param :organization_id, :number, :desc => N_('Organization identifier'), :required => true
    param_group :content_credential, :as => :create
    def create
      filepath = params.try(:[], :file_path).try(:path)

      content = nil
      if filepath
        content = File.read(filepath, mode: 'rb')
      else
        content = params[:content]
      end

      content_credential = @organization.gpg_keys.create!(content_credential_params.merge(:content => content))
      respond_for_create(:resource => content_credential)
    end

    api :GET, "/content_credentials/:id", N_('Show a Content Credential')
    param :id, :number, :desc => N_('Content Credential numeric identifier'), :required => true
    def show
      respond_for_show(:resource => @content_credential)
    end

    api :PUT, "/content_credentials/:id", N_('Update a Content Credential')
    param :id, :number, :desc => N_('Content Credential ID'), :required => true
    param_group :content_credential
    def update
      sync_task(::Actions::Katello::GpgKey::Update, @content_credential, content_credential_params.to_h)
      respond_for_show(:resource => @content_credential)
    end

    api :DELETE, "/content_credentials/:id", N_('Destroy a Content Credential')
    param :id, :number, :desc => N_('Content Credential ID'), :required => true
    def destroy
      @content_credential.destroy
      respond_for_destroy
    end

    api :GET, "/content_credentials/:id/content", N_('Return the content of a Content Credential, used directly by yum')
    param :id, :number, :required => true
    def content
      render(:plain => @content_credential.content, :layout => false)
    end

    api :POST, "/content_credentials/:id/content", N_('Upload Content Credential contents')
    param :id, :number, :desc => N_('Content Credential ID'), :required => true
    param :content, File, :desc => N_('File contents'), :required => true
    def set_content
      filepath = params.try(:[], :content).try(:path)

      if filepath
        content = File.open(filepath, 'rb') { |file| file.read }
        @content_credential.update!(:content => content)
        render :json => {:status => 'success'}
      else
        fail HttpErrors::BadRequest, _('No file uploaded')
      end
    end

    protected

    def content_credential_params
      params.permit(:name, :content_type, :content)
    end
  end
end
