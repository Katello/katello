class FiltersController < ApplicationController

  include AutoCompleteSearch

  before_filter :panel_options, :only=>[:index, :items]


  
  def rules
    allow = lambda{true}

    {
      :index => allow,
      :show => allow



    }
  end





  def index
    #readable(current_organization)
    @filters = Filter.search_for(params[:search]).order('pulp_id desc').
        limit(current_user.page_size)


  end

  def items
    start = params[:offset]
    @filters = Filter.readable(current_organization).search_for(params[:search]).order('pulp_id desc').
        limit(current_user.page_size).offset(start)
    render_panel_items @providers, @panel_options
  end

  def new
    
  end


  private

  def panel_options
    @panel_options = {
        :title => _('Package Filters'),
        :col => ['name'],
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
