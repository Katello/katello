module Katello
  class Api::V2::ContentViewComponentsController < Api::V2::ApiController
    before_action :find_composite_content_view
    before_action :find_content_view_component, :only => [:show, :update]

    wrap_parameters :include => %w(composite_content_view_id content_view_version_id content_view_id latest)

    api :GET, "/content_views/:composite_content_view_id/content_view_components",
        N_("List components attached to this content view")
    param :composite_content_view_id, :identifier, :desc => N_("composite content view identifier"), :required => true
    def index
      respond :collection => index_response
    end

    def index_response
      results = @view.content_view_components
      {
        :results  => results.uniq,
        :subtotal => results.count,
        :total    => results.count
      }
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/add",
                                        N_("Add components to the content view")
    param :composite_content_view_id, :identifier, :desc => N_("composite content view identifier"), :required => true
    param :components, Array, :desc => N_("Array of components to add"), :required => true do
      param :content_view_version_id, :identifier, :desc => N_("identifier of the version of the component content view")
      param :content_view_id, :identifier,
            :desc => N_("content view identifier of the component who's latest version is desired")
      param :latest, :bool, :desc => N_("true if the latest version of the component's content view is desired")
    end
    def add_components
      components = params.require(:components).map do |component|
        options = {}
        options[:latest] = ::Foreman::Cast.to_bool(component[:latest]) if component.key?(:latest)
        options.merge(component.slice(:content_view_version_id, :content_view_id))
      end
      @view.add_components(components)
      @view.save!
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/remove",
                                        N_("Remove components from the content view")
    param :composite_content_view_id, :identifier, :desc => N_("composite content view identifier"), :required => true
    param :component_ids, Array, :desc => N_("Array of content view component IDs to remove. Identifier of the component association"), :required => true
    def remove_components
      @view.remove_components(params.require(:component_ids))
      @view.save!
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :GET, "/content_views/:composite_content_view_id/content_view_components/:id", N_("Show a content view component")
    param :composite_content_view_id, :number, :desc => N_("composite content view numeric identifier"), :required => true
    param :id, :identifier, :desc => N_("content view component ID. Identifier of the component association"), :required => true
    def show
      respond :resource => @component
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/:id",
        N_("Update a component associated with the content view")
    param :composite_content_view_id, :identifier, :desc => N_("composite content view identifier"), :required => true
    param :id, :identifier, :desc => N_("content view component ID. Identifier of the component association"), :required => true
    param :content_view_version_id, :identifier, :desc => N_("identifier of the version of the component content view")
    param :latest, :bool, :desc => N_("true if the latest version of the components content view is desired")
    def update
      cvv_id = component_params[:content_view_version_id]
      if component_params.key?(:latest) && component_params.key?(:content_view_version_id)
        latest = ::Foreman::Cast.to_bool(component_params[:latest])
        if latest && cvv_id.present?
          fail HttpErrors::UnprocessableEntity,
              _(" Either select the latest content view or the content view version. Cannot set both.")
        end
      end
      if cvv_id.present?
        @component.update_attributes!(:content_view_version_id => cvv_id, :latest => false)
      elsif component_params.key?(:latest)
        latest = ::Foreman::Cast.to_bool(component_params[:latest])
        @component.update_attributes!(:content_view_version_id => nil, :latest => latest)
      end
      respond :resource => @component
    end

    private

    def find_composite_content_view
      @view = ContentView.composite.non_default.find(params[:composite_content_view_id])
    end

    def find_content_view_component
      @component = ContentViewComponent.find(params[:id])
    end

    def component_params
      attrs = [:latest, :content_view_version_id, :content_view_id]
      params.require(:content_view_component).permit(*attrs)
    end
  end
end
