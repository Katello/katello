class FiltersController < ApplicationController

  include AutoCompleteSearch

  skip_before_filter :authorize
  before_filter :panel_options, :only=>[:index, :items]
  before_filter :find_filter, :only=>[:show, :update, :destroy]
  before_filter :authorize

  def rules
    
    create = lambda{Filter.creatable?(current_organization)}
    index_test = lambda{Filter.any_readable?(current_organization)}
    readable = lambda{@filter.readable?}
    {
      :create => create,
      :new => create,
      :index => index_test,
      :items => index_test,
      :auto_complete_search => index_test,
      :show => readable

    }
  end


  def index
    @filters = Filter.readable(current_organization).search_for(params[:search]).order('pulp_id desc').
        limit(current_user.page_size)
  end

  def items
    start = params[:offset]
    @filters = Filter.readable(current_organization).search_for(params[:search]).order('pulp_id desc').
        limit(current_user.page_size).offset(start)
    render_panel_items @providers, @panel_options
  end


  def new
    @filter = Filter.new
    render :partial => "new", :layout => "tupane_layout"
  end

  def create
    @filter = Filter.create!(params[:filter].merge({:organization_id=>current_organization.id}))
    notice N_("Filter #{@filter.pulp_id} created successfully.")
    render :partial=>"common/list_item", :locals=>{:item=>@filter, :accessor=>"id", :columns=>['pulp_id'], :name=>controller_display_name}

  rescue Exception=> e
    errors e
    render :text=>e, :status=>500
  end

  private

  def find_filter
    @filter = Filter.find(params[:id])
  end

  def panel_options
    @panel_options = {
        :title => _('Package Filters'),
        :col => ['pulp_id'],
        :create => _('Filter'),
        :name => controller_display_name,
        :ajax_scroll=>items_filters_path(),
        :enable_create=> Filter.creatable?(current_organization)
    }
  end

  def controller_display_name
    return _('filter')
  end

end
