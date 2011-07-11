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
  before_filter :find_system, :except =>[:index, :auto_complete_search, :items]
  before_filter :setup_options, :only => [:index, :items]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name', 'lastCheckin' => 'lastCheckin', 'created' => 'created_at' }
  
  def index
    begin
      @systems = System.search_for(params[:search]).where(:environment_id => current_organization.environments).limit(current_user.page_size)
      retain_search_history
      sort_columns(COLUMNS,@systems) if params[:order]
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @systems = System.search_for ''
      render :index, :status=>:bad_request
    end
  end

  def items
    start = params[:offset]
    @systems = System.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @systems, @panel_options
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

  def subscriptions
    all = @system.pools + @system.available_pools
    consumed = @system.consumed_pool_ids
    all_pools = all.collect {|pool| OpenStruct.new(:poolId => pool["id"], :poolName => pool["productName"])}
    all_pools.sort! {|a,b| a.poolName <=> b.poolName}
    render :partial=>"subscriptions", :locals=>{:system=>@system, :all_subs => all_pools, :consumed => consumed}
  end

  def update_subscriptions
    params[:system] = {"consumed_pool_ids"=>[]} unless params.has_key? :system
    if @system.update_attributes(params[:system])
      notice _("System subscriptions updated.")
      render :nothing =>true
    else
      errors "Unable to update subscriptions."
      render :nothing =>true
    end
  end
  
  def packages
    packages = @system.packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    render :partial=>"packages", :locals=>{:system=>@system, :packages => packages}
  end
  
  def edit
     render :partial=>"edit", :locals=>{:system=>@system}
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
    render :partial=>"common/list_update", :locals=>{:item=>system, :accessor=>"id", :columns=>['name', 'ip', 'kernel']}
  end
  
  def section_id
    'systems'
  end
  
  def facts
    render :partial => 'facts'
  end    

  private
  include SortColumnList
  
  def find_system
    @system = System.find(params[:id])
  end

end
