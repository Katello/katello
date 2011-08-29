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

class SyncPlansController < ApplicationController
  include AutoCompleteSearch

  before_filter :get_plan, :only => [:destroy, :edit, :show]
  before_filter :setup_options, :only => [:index, :items]

  def section_id
    'contents'
  end


  def rules
    read_test = lambda{Provider.any_readable?(current_organization)}
    manage_test = lambda{current_organization.syncable?}
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,
      :edit => read_test,
      :update => manage_test,
      :destroy => manage_test,
      :new => manage_test,
      :create => manage_test,
    }
  end


  def index
    begin
      @plans = SyncPlan.search_for(params[:search]).where(:organization_id => current_organization.id).limit(current_user.page_size)
      retain_search_history
    rescue Exception => e
      errors e.to_s, {:level => :message, :persist => false}
      @plans = SyncPlan.search_for ''
    end
  end
  
  def items
    start = params[:offset]
    @sync_plans = SyncPlan.search_for(params[:search]).where(:organization_id => current_organization.id).limit(current_user.page_size).offset(start)
    render_panel_items @sync_plans, @panel_options
  end
  
  def setup_options
    columns = ['name', 'interval']
    @panel_options = { :title => _('Sync Plans'),
                 :col => columns,
                 :create => _('Plan'),
                 :name => _('plan'),
                 :javascript_id => javascript_id,
                 :ajax_scroll => items_sync_plans_path(),
                 :enable_create => current_organization.syncable? } 
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout",
           :locals => {:plan=>@plan, :editable=> current_organization.syncable?, :javascript_id=>javascript_id + @plan.id.to_s } 
  end

  def update
    begin
      updated_plan = SyncPlan.find(params[:id])
      result = params[:sync_plan].values.first

      updated_plan.name = params[:sync_plan][:name] unless params[:sync_plan][:name].nil?
      updated_plan.interval = params[:sync_plan][:interval] unless params[:sync_plan][:interval].nil?

      unless params[:sync_plan][:description].nil?
        result = updated_plan.description = params[:sync_plan][:description].gsub("\n",'')
      end

      unless params[:sync_plan][:time].nil?
        ttime = updated_plan.plan_date + ' ' + params[:sync_plan][:time].strip
        updated_plan.sync_date = DateTime.strptime(ttime, '%m/%d/%Y %I:%M %p')
      end

      unless params[:sync_plan][:date].nil?
        ddate = params[:sync_plan][:date].strip + ' ' + updated_plan.plan_time
        updated_plan.sync_date = DateTime.strptime(ddate, '%m/%d/%Y %I:%M %p')
      end

      updated_plan.save!
      notice N_("Sync Plan '#{updated_plan.name}' was updated.")

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

      rescue Exception => e
        errors e.to_s

        respond_to do |format|
          format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
          format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        end
    end

  end

  def destroy
    @id = @plan.id
    begin
      @plan.destroy
      notice N_("Sync plan '#{@plan[:name]}' was deleted.")
    rescue Exception => e
      errors e.to_s
    end
    render :partial => "common/list_remove", :locals => {:javascript_id=>javascript_id + @id.to_s}
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval']}
  end

  def new
    @plan = SyncPlan.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:plan => @plan}
  end

  def create
    begin
      sdate = params[:sync_plan].delete :plan_date
      stime = params[:sync_plan].delete :plan_time
      sync_event = sdate + ' ' + stime
      begin
        params[:sync_plan][:sync_date] = DateTime.strptime(sync_event, "%m/%d/%Y %I:%M %P")
      rescue Exception => error
        params[:sync_plan][:sync_date] = nil
      end
      @plan = SyncPlan.create! params[:sync_plan].merge({:organization => current_organization})
      notice N_("Sync Plan '#{@plan['name']}' was created.")
      render :partial=>"common/list_item", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval'], :javascript_id=>javascript_id}
    rescue Exception => error
      Rails.logger.error error.to_s
      errors error
      render :text => error, :status => :bad_request
    end
  end
  
  protected
  # pre filter for grabbing plan object
  def get_plan
    begin
      @plan = SyncPlan.find(params[:id])
    rescue Exception => error
      errors error.to_s
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
      
      
  def javascript_id
    return "#{_('sync_plan')}_"
  end
end
