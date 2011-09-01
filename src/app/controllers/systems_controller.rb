#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class SystemsController < ApplicationController
  include AutoCompleteSearch
  include SystemsHelper


  before_filter :find_system, :except =>[:index, :auto_complete_search, :items, :environments]

  skip_before_filter :authorize
  before_filter :find_environment, :only => [:environments, :env_items]
  before_filter :authorize

  before_filter :setup_options, :only => [:index, :items, :environments]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name', 'lastCheckin' => 'lastCheckin', 'created' => 'created_at' }


  def rules
    edit_system = lambda{System.find(params[:id]).editable?}
    read_system = lambda{System.find(params[:id]).readable?}
    delete_system = lambda{ System.find(params[:id]).deletable? }
    env_system = lambda{@environment.systems_readable?}

    {
      :index => lambda{true},
      :items => lambda{true},
      :environments => env_system,
      :env_items => env_system,
      :subscriptions => read_system,
      :update_subscriptions => edit_system,
      :packages => read_system,
      :update => edit_system,
      :edit => read_system,
      :show => read_system,
      :facts => read_system
    }
  end

  def index
    begin
      @systems = System.readable(current_organization).search_for(params[:search]).limit(current_user.page_size)
      retain_search_history
      sort_columns(COLUMNS,@systems) if params[:order]
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @systems = System.search_for ''
      render :index, :status=>:bad_request
    end
  end

  def environments
    accesible_envs = KTEnvironment.systems_readable(current_organization)

    @panel_options[:ajax_scroll] = env_items_systems_path()
    begin

      @systems = []

      setup_environment_selector(current_organization, accesible_envs)
      if @environment
        @systems = System.search_for(params[:search]).where(:environment_id => @environment.id).limit(current_user.page_size) 
        retain_search_history
        sort_columns(COLUMNS,@systems) if params[:order]
      end
      render :index, :locals=>{:envsys => 'true', :accessible_envs=> accesible_envs}
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @systems = System.search_for ''
      render :index, :status=>:bad_request
    end
  end

  def items
    start = params[:offset]
    @systems = System.readable(current_organization).search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @systems, @panel_options
  end

  def env_items
    start = params[:offset]
    @systems = System.readable(current_organization).search_for(params[:search]).where(:environment_id => @environment.id).limit(current_user.page_size).offset(start)
    render_panel_items @systems, @panel_options
  end

  def subscriptions

    consumed_pools = @system.pools.collect {|pool| OpenStruct.new(:poolId => pool["id"], 
                            :poolName => pool["productName"],
                            :expires => Date.parse(pool["endDate"]).strftime("%m/%d/%Y"),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    consumed_pools.sort! {|a,b| a.poolName <=> b.poolName}

    avail_pools = @system.pools.collect {|pool| OpenStruct.new(:poolId => pool["id"], 
                            :poolName => pool["productName"],
                            :expires => Date.parse(pool["endDate"]).strftime("%m/%d/%Y"),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    avail_pools.sort! {|a,b| a.poolName <=> b.poolName}

    render :partial=>"subscriptions", :layout => "tupane_layout", 
                                      :locals=>{:system=>@system, :avail_subs => avail_pools,
                                                :consumed_subs => consumed_pools, :editable=>@system.editable?}
  end

  def update_subscriptions
    params[:system] = {"consumed_pool_ids"=>[]} unless params.has_key? :system
    if @system.update_attributes(params[:system])
      notice _("System subscriptions updated.")
      render :nothing =>true
    else
      errors _("Unable to update subscriptions.")
      render :nothing =>true
    end
  end

  def packages
    packages = @system.simple_packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    packages = packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    render :partial=>"packages", :layout => "tupane_layout", :locals=>{:system=>@system, :packages => packages}
  end

  def more_packages
    packages = []
    render :partial=>"more_packages", :locals=>{:system=>@system, :packages => packages}
  end
  
  def edit
     render :partial=>"edit", :layout=>"tupane_layout", :locals=>{:system=>@system, :editable=>@system.editable?}
  end  

  def update
    begin 
      @system.update_attributes(params[:system])
      notice _("System updated.")
      
      respond_to do |format|
        format.html { render :text=>params[:system].first[1] }
        format.js  
      end
      
    rescue Exception => e
      errors @system.errors
      respond_to do |format|
        format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def show
    system = System.find(params[:id])
    render :partial=>"systems/list_system_show", :locals=>{:item=>system, :accessor=>"id", :columns=> COLUMNS.keys, :noblock => 1}
  end
  
  def section_id
    'systems'
  end
  
  def facts
    render :partial => 'facts', :layout => "tupane_layout"
  end    

  private
  include SortColumnList


  def find_environment
    readable = KTEnvironment.systems_readable(current_organization)
    @environment = KTEnvironment.find(params[:env_id]) if params[:env_id]
    @environment ||= first_env_in_path(readable, false)
    @environment ||=  current_organization.locker
  end

  def find_system
    @system = System.find(params[:id])
  end

  def setup_options
    @panel_options = { :title => _('Systems'),
                      :col => COLUMNS.keys,
                      :custom_rows => true,
                      :enable_create => false,
                      :enable_sort => true,
                      :name => _('system'),
                      :list_partial => 'systems/list_systems',
                      :ajax_scroll => items_systems_path()}
  end


end
