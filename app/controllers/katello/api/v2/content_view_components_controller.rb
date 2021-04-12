module Katello
  class Api::V2::ContentViewComponentsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_composite_content_view, :only => [:show, :index]
    before_action :find_composite_content_view_for_edit, :only => [:add_components, :remove_components, :update]
    before_action :find_authorized_katello_resource, :only => [:show, :update]

    wrap_parameters :include => %w(composite_content_view_id content_view_version_id content_view_id latest)

    api :GET, "/content_views/:composite_content_view_id/content_view_components",
        N_("List components attached to this content view")
    param :composite_content_view_id, :number, :desc => N_("composite content view identifier"), :required => true
    def index
      sort_by, sort_order, options = sort_options
      respond(:collection => scoped_search(index_relation, sort_by, sort_order, options))
    end

    def index_relation
      @view.content_view_components.readable
    end

    def index_response
      results = @view.content_view_components.readable
      {
        :results => results.uniq,
        :subtotal => results.count,
        :total => results.count
      }
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/add",
                                        N_("Add components to the content view")
    param :composite_content_view_id, :number, :desc => N_("composite content view identifier"), :required => true
    param :components, Array, :desc => N_("Array of components to add"), :required => true do
      param :content_view_version_id, :number, :desc => N_("identifier of the version of the component content view")
      param :content_view_id, :number,
            :desc => N_("content view identifier of the component who's latest version is desired")
      param :latest, :bool, :desc => N_("true if the latest version of the component's content view is desired")
    end
    def add_components
      @view.add_components(authorized_components)
      @view.save!
      respond_for_index(:collection => index_response, :template => "index")
    end

    private def authorized_components
      components = params.require(:components).map do |component|
        component = component.permit([:latest, :content_view_version_id, :content_view_id])
        options = {}
        options[:latest] = ::Foreman::Cast.to_bool(component[:latest]) if component.key?(:latest)
        options.merge(component.slice(:content_view_version_id, :content_view_id)).with_indifferent_access
      end

      components.each do |component|
        if component[:content_view_version_id] && Katello::ContentViewVersion.readable.find_by(id: component[:content_view_version_id]).nil?
          throw_resource_not_found(name: 'content_view_version', id: component[:content_view_version_id])
        elsif component[:content_view_id] && Katello::ContentView.readable.find_by(id: component[:content_view_id]).nil?
          throw_resource_not_found(name: 'content_view', id: component[:content_view_id])
        end
      end
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/remove",
                                        N_("Remove components from the content view")
    param :composite_content_view_id, :number, :desc => N_("composite content view identifier"), :required => true
    param :component_ids, Array, :desc => N_("Array of content view component IDs to remove. Identifier of the component association"), :required => true
    def remove_components
      @view.remove_components(params.require(:component_ids))
      @view.save!
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :GET, "/content_views/:composite_content_view_id/content_view_components/:id", N_("Show a content view component")
    param :composite_content_view_id, :number, :desc => N_("composite content view numeric identifier"), :required => true
    param :id, :number, :desc => N_("content view component ID. Identifier of the component association"), :required => true
    def show
      respond :resource => @content_view_component
    end

    api :PUT, "/content_views/:composite_content_view_id/content_view_components/:id",
        N_("Update a component associated with the content view")
    param :composite_content_view_id, :number, :desc => N_("composite content view identifier"), :required => true
    param :id, :number, :desc => N_("content view component ID. Identifier of the component association"), :required => true
    param :content_view_version_id, :number, :desc => N_("identifier of the version of the component content view")
    param :latest, :bool, :desc => N_("true if the latest version of the components content view is desired")
    def update
      cvv_id = component_params[:content_view_version_id]
      if cvv_id && Katello::ContentViewVersion.readable.find_by(id: cvv_id).nil?
        throw_resource_not_found(name: 'content view version', id: cvv_id)
      end
      if component_params.key?(:latest) && component_params.key?(:content_view_version_id)
        latest = ::Foreman::Cast.to_bool(component_params[:latest])
        if latest && cvv_id.present?
          fail HttpErrors::UnprocessableEntity,
              _(" Either select the latest content view or the content view version. Cannot set both.")
        end
      end
      if cvv_id.present?
        @content_view_component.update!(:content_view_version_id => cvv_id, :latest => false)
      elsif component_params.key?(:latest)
        latest = ::Foreman::Cast.to_bool(component_params[:latest])
        @content_view_component.update!(:content_view_version_id => nil, :latest => latest)
      end
      respond :resource => @content_view_component
    end

    private

    def find_composite_content_view
      @view = ContentView.composite.non_default.readable.find_by(id: params[:composite_content_view_id])
      throw_resource_not_found(name: 'composite content view', id: params[:composite_content_view_id]) if @view.nil?
    end

    def find_composite_content_view_for_edit
      @view = ContentView.composite.non_default.editable.find_by(id: params[:composite_content_view_id])
      throw_resource_not_found(name: 'composite content view', id: params[:composite_content_view_id]) if @view.nil?
    end

    def component_params
      attrs = [:latest, :content_view_version_id, :content_view_id]
      params.require(:content_view_component).permit(*attrs)
    end

    def default_sort
      %w(label asc)
    end

    def sort_options
      case default_sort
      when Array
        [default_sort[0], default_sort[1], {}]
      when Proc
        [nil, nil, { :custom_sort => default_sort }]
      else
        fail "Unsupported default_sort type"
      end
    end
  end
end
