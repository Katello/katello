module Katello
  class Api::V2::ContentViewPuppetModulesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_content_view, :except => [:autocomplete_search]
    before_filter :find_puppet_module, :only => [:show, :update, :destroy]

    api :GET, "/content_views/:content_view_id/content_view_puppet_modules", N_("List content view puppet modules")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("name of the puppet module")
    param :author, String, :desc => N_("author of the puppet module")
    param :uuid, String, :desc => N_("the uuid of the puppet module to associate")
    param_group :search, ::Katello::Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :desc))
    end

    api :POST, "/content_views/:content_view_id/content_view_puppet_modules",
        N_("Add a puppet module to the content view")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("name of the puppet module")
    param :author, String, :desc => N_("author of the puppet module")
    param :uuid, String, :desc => N_("the uuid of the puppet module to associate")
    def create
      @puppet_module = ContentViewPuppetModule.create!(puppet_module_params) do |puppet_module|
        puppet_module.content_view = @view
      end

      respond :resource => @puppet_module
    end

    api :GET, "/content_views/:content_view_id/content_view_puppet_modules/:id", N_("Show a content view puppet module")
    param :content_view_id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :id, :identifier, :desc => N_("puppet module ID"), :required => true
    def show
      respond :resource => @puppet_module
    end

    api :PUT, "/content_views/:content_view_id/content_view_puppet_modules/:id",
        N_("Update a puppet module associated with the content view")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :id, :identifier, :desc => N_("puppet module ID"), :required => true
    param :name, String, :desc => N_("name of the puppet module")
    param :author, String, :desc => N_("author of the puppet module")
    param :uuid, String, :desc => N_("the uuid of the puppet module to associate")
    def update
      @puppet_module.update_attributes!(puppet_module_params)
      respond :resource => @puppet_module
    end

    api :DELETE, "/content_views/:content_view_id/content_view_puppet_modules/:id",
        N_("Remove a puppet module from the content view")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :id, :identifier, :desc => N_("puppet module ID"), :required => true
    def destroy
      @puppet_module.destroy
      respond :resource => @puppet_module
    end

    def index_relation
      puppet_modules = ContentViewPuppetModule.where(:content_view_id => @view)
      puppet_modules = puppet_modules.where(:name => params[:name]) if params[:name]
      puppet_modules = puppet_modules.where(:uuid => params[:uuid]) if params[:uuid]
      puppet_modules = puppet_modules.where(:author => params[:author]) if params[:author]
      puppet_modules
    end

    private

    def find_content_view
      @view = ContentView.non_default.find(params[:content_view_id])
    end

    def find_puppet_module
      @puppet_module = ContentViewPuppetModule.find(params[:id])
    end

    def puppet_module_params
      attrs = [:name, :author, :uuid]
      params.require(:content_view_puppet_module).permit(*attrs)
    end
  end
end
