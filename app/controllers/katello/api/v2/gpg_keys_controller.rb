module Katello
  class Api::V2::GpgKeysController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :deprecated
    before_action :authorize
    before_action :find_organization, :only => [:create, :index, :auto_complete_search]
    before_action :find_gpg_key, :only => [:show, :update, :destroy, :content, :set_content]
    skip_before_action :check_media_type, :only => [:create, :content, :set_content]

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
    add_scoped_search_description_for(GpgKey)
    def index
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc))
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
      respond_for_create(:resource => gpg_key)
    end

    api :GET, "/gpg_keys/:id", N_("Show a gpg key")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    def show
      respond_for_show(:resource => @gpg_key)
    end

    api :PUT, "/gpg_keys/:id", N_("Update a repository")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    param_group :gpg_key
    def update
      sync_task(::Actions::Katello::GpgKey::Update, @gpg_key, gpg_key_params.to_h)

      respond_for_show(:resource => @gpg_key)
    end

    api :DELETE, "/gpg_keys/:id", N_("Destroy a gpg key")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    def destroy
      @gpg_key.destroy
      respond_for_destroy
    end

    api :GET, "/gpg_keys/:id/content", N_("Return the content of a gpg key, used directly by yum")
    param :id, :number, :required => true
    def content
      render(:plain => @gpg_key.content, :layout => false)
    end

    api :POST, "/gpg_keys/:id/content", N_("Upload gpg key contents")
    param :id, :number, :desc => N_("gpg key numeric identifier"), :required => true
    param :content, File, :desc => N_("file contents"), :required => true
    def set_content
      filepath = params.try(:[], :content).try(:path)

      if filepath
        content = File.open(filepath, "rb") { |file| file.read }
        @gpg_key.update!(:content => content)
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

    def deprecated
      ::Foreman::Deprecation.api_deprecation_warning("it will be removed in Katello 4.0, Please see /api/v2/content_credentials")
    end
  end
end
