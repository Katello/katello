module Katello
  class Api::V2::ContentViewComponentsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_composite_content_view, :only => [:show, :index, :show_all]
    before_action :find_composite_content_view_for_edit, :only => [:add_components, :remove_components, :update]
    before_action :find_authorized_katello_resource, :only => [:show, :update]
    before_action :find_organization_from_cv, :only => [:show_all]

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
        :total => results.count,
      }
    end

    # content_views/:id/components/show_all
    # Shows all content views, added and available to add, for a content view
    # Undocumented endpoint since the functionality exists in separate calls already.
    # This was created for ease of pagination and search for the UI
    # param :id, :number, desc: N_("Content View id"), required: true
    # param :status, ["Added", "Not added", "All"], :desc => N_("Filter to show added, not added or all components")
    def show_all
      kc = Katello::ContentView.table_name
      kcc = Katello::ContentViewComponent.table_name
      join_query = <<-SQL
         LEFT OUTER JOIN #{kcc}
         ON #{kc}.id = #{kcc}.content_view_id
         AND #{kcc}.composite_content_view_id = #{@view.id}
      SQL
      order_query = <<-SQL
         CAST (#{kcc}.composite_content_view_id as BOOLEAN) ASC, #{kc}.name
      SQL
      query = Katello::ContentView.readable.in_organization(@organization)
      query = query&.non_composite&.non_default&.non_rolling&.generated_for_none
      component_cv_ids = Katello::ContentViewComponent.where(composite_content_view_id: @view.id).select(:content_view_id)
      query = case params[:status]
              when "Not added"
                query.where.not(id: component_cv_ids)
              when "Added"
                query.where(id: component_cv_ids)
              else
                query
              end
      custom_sort = ->(sort_query) { sort_query.joins(join_query).order(Arel.sql(order_query)) }
      options = { resource_class: Katello::ContentView, custom_sort: custom_sort }
      collection = scoped_search(query, nil, nil, options)
      collection[:results] = ComponentViewPresenter.component_presenter(@view, params[:status], views: collection[:results])
      respond_for_index(:collection => collection, :template => "index")
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

    def get_total(status)
      case status
      when 'All'
        return Katello::ContentView.non_default.non_composite.non_rolling.in_organization(@organization).count
      when 'Added'
        return Katello::ContentViewComponent.where(composite_content_view_id: @view.id).count
      when 'Not added'
        return Katello::ContentView.non_default.non_composite.non_rolling.in_organization(@organization).count - Katello::ContentViewComponent.where(composite_content_view_id: @view.id).count
      else
        return Katello::ContentView.non_default.non_composite.non_rolling.in_organization(@organization).count
      end
    end

    def find_composite_content_view
      @view = ContentView.composite.non_default.non_rolling.readable.find_by(id: params[:composite_content_view_id])
      throw_resource_not_found(name: 'composite content view', id: params[:composite_content_view_id]) if @view.nil?
    end

    def find_composite_content_view_for_edit
      @view = ContentView.composite.non_default.non_rolling.editable.find_by(id: params[:composite_content_view_id])
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

    def find_organization_from_cv
      @organization = @view.organization
    end
  end
end
