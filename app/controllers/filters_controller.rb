class FiltersController < ApplicationController

  include AutoCompleteSearch

  skip_before_filter :authorize
  before_filter :panel_options, :only=>[:index, :items]
  before_filter :find_filter, :only=>[:edit, :update, :destroy]
  before_filter :authorize

  def rules
    
    create = lambda{Filter.creatable?(current_organization)}
    index_test = lambda{Filter.any_readable?(current_organization)}
    readable = lambda{@filter.readable?}
    editable = lambda{@filter.editable?}
    deletable = lambda{@filter.deletable?}
    {
      :create => create,
      :new => create,
      :index => index_test,
      :items => index_test,
      :auto_complete_search => index_test,
      :edit => readable,
      :update=>editable,
      :destroy=>deletable

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

  def update
    options = params[:filter]
    to_ret = ""
    if options[:name]
      @filter.name = options[:name]
      to_ret =  @filter.name
    elsif options[:description]
      @filter.description = options[:description]
      to_ret = @filter.description 
    end
    @filter.save!
    notice _("Package Filter '#{@filter.name}' has been updated.")
    render :text=>to_ret
  rescue Exception=>e
    errors e
    render :text=>e, :status=>500
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:filter => @filter, :editable=>@filter.editable?,
                                                                       :name=>controller_display_name}
  end

  def new
    @filter = Filter.new
    render :partial => "new", :layout => "tupane_layout"
  end

  def create
    @filter = Filter.create!(params[:filter].merge({:organization_id=>current_organization.id}))
    notice N_("Filter #{@filter.name} created successfully.")
    render :partial=>"common/list_item", :locals=>{:item=>@filter, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}

  rescue Exception=> e
    errors e
    render :text=>e, :status=>500
  end


  def destroy
    @filter.destroy
    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
  rescue Exception => e
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
