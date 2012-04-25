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
  before_filter :search_filter, :only => [:auto_complete_search]

  def section_id
    'contents'
  end

  def rules
    read_test = lambda{current_organization && Provider.any_readable?(current_organization)}
    manage_test = lambda{current_organization && current_organization.syncable?}
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,
      :auto_complete_search => read_test,
      :edit => read_test,
      :update => manage_test,
      :destroy => manage_test,
      :new => manage_test,
      :create => manage_test,
    }
  end
  
  def items
    render_panel_direct(SyncPlan, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
                        {:default_field => :name, :filter=>{:organization_id=>[current_organization.id]}})
    
  end
  
  def setup_options
    @panel_options = { :title => _('Sync Plans'),
                 :col =>  ['name', 'interval'],
                  :titles => [_('Name'), _("Interval") ],
                 :create => _('Plan'),
                 :name => controller_display_name,
                 :ajax_load => true,
                 :ajax_scroll => items_sync_plans_path(),
                 :enable_create => current_organization.syncable?,
                 :search_class=>SyncPlan}
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout",
           :locals => {:plan=>@plan, :editable=> current_organization.syncable?, :name=>controller_display_name } 
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

      if params[:sync_plan][:time]
        updated_plan.sync_date = convert_date_time(updated_plan.plan_date, params[:sync_plan][:time].strip)
      end

      if params[:sync_plan][:date]
        updated_plan.sync_date = convert_date_time(params[:sync_plan][:date].strip, updated_plan.plan_time)
      end

      updated_plan.save!
      notice N_("Sync Plan '%s' was updated.") % updated_plan.name

      if not search_validate(SyncPlan, updated_plan.id, params[:search])
        notice _("'%s' no longer matches the current search criteria.") % updated_plan["name"], { :level => 'message', :synchronous_request => false }
      end

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

      rescue Exception => e
        notice e.to_s, {:level => :error}

        respond_to do |format|
          format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
          format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        end
    end

  end

  #convert date, time from UI to object
  def convert_date_time(date, time)
    sync_event = date + ' ' + time + ' '  + DateTime.now.zone
    DateTime.strptime(sync_event, "%m/%d/%Y %I:%M %P %:z")
  end

  def destroy
    @id = @plan.id
    begin
      @plan.destroy
      notice N_("Sync plan '%s' was deleted.") % @plan[:name]
    rescue Exception => e
      notice e.to_s, {:level => :error}
    end
    render :partial => "common/list_remove", :locals => {:id=>@id, :name=>controller_display_name}
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval']}
  end

  def new
    @plan = SyncPlan.new
    @plan.sync_date = DateTime.now
    render :partial => "new", :layout => "tupane_layout", :locals => {:plan => @plan}
  end

  def param_rules
    {
      :create => {:sync_plan => [:description, :name, :interval, :plan_date, :plan_time]},
      :update => {:sync_plan => [:description, :name, :interval, :date, :time]},
    }
  end

  def create
    begin
      sdate = params[:sync_plan].delete :plan_date
      stime = params[:sync_plan].delete :plan_time
      begin
        params[:sync_plan][:sync_date] = convert_date_time(sdate, stime)
      rescue
        params[:sync_plan][:sync_date] = nil
      end
      
      @plan = SyncPlan.create! params[:sync_plan].merge({:organization => current_organization})
      notice N_("Sync Plan '%s' was created.") % @plan['name']
      
      if search_validate(SyncPlan, @plan.id, params[:search])
        render :partial=>"common/list_item", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval'], :name=>controller_display_name}
      else
        notice _("'%s' did not meet the current search criteria and is not being shown.") % @plan["name"], { :level => 'message', :synchronous_request => false }
        render :json => { :no_match => true }
      end
    rescue Exception => e
      Rails.logger.error e.to_s
      notice e, {:level => :error}
      render :text => e, :status => :bad_request
    end
  end
  
  protected
  # pre filter for grabbing plan object
  def get_plan
    begin
      @plan = SyncPlan.find(params[:id])
    rescue Exception => error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
      
  def controller_display_name
    return 'sync_plan'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
