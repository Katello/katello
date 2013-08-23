#
# Copyright 2013 Red Hat, Inc.
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
                 :create_label => _('+ New Plan'),
                 :name => controller_display_name,
                 :ajax_load => true,
                 :ajax_scroll => items_sync_plans_path(),
                 :enable_create => current_organization.syncable?,
                 :search_class=>SyncPlan}
  end

  def edit
    render :partial => "edit",
           :locals => {:plan=>@plan, :editable=> current_organization.syncable?, :name=>controller_display_name }
  end

  def update
    updated_plan = SyncPlan.find(params[:id])
    result = params[:sync_plan].values.first

    updated_plan.name = params[:sync_plan][:name] unless params[:sync_plan][:name].nil?
    updated_plan.interval = params[:sync_plan][:interval] unless params[:sync_plan][:interval].nil?

    unless params[:sync_plan][:description].nil?
      result = updated_plan.description = params[:sync_plan][:description].gsub("\n",'')
    end

    if params[:sync_plan][:time]
      updated_plan.sync_date = convert_date_time(updated_plan.plan_date, params[:sync_plan][:time].strip)
      return render_bad_parameters(_('Invalid date or time format')) unless updated_plan.sync_date
    end

    if params[:sync_plan][:date]
      updated_plan.sync_date = convert_date_time(params[:sync_plan][:date].strip, updated_plan.plan_time)
      return render_bad_parameters(_('Invalid date or time format')) unless updated_plan.sync_date
    end

    updated_plan.save!
    notify.success N_("Sync Plan '%s' was updated.") % updated_plan.name

    if !search_validate(SyncPlan, updated_plan.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % updated_plan["name"]
    end

    render :text => escape_html(result)
  end

  #convert date, time from UI to object
  def convert_date_time(date, time)
    return nil if date.blank? || time.blank?
    parse_calendar_date(date, time)
  end

  def destroy
    if @plan.destroy
      notify.success N_("Sync plan '%s' was deleted.") % @plan[:name]
    end

    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval']}
  end

  def new
    @plan = SyncPlan.new
    @plan.sync_date = DateTime.now
    render :partial => "new", :locals => {:plan => @plan}
  end

  def param_rules
    {
      :create => {:sync_plan => [:description, :name, :interval, :plan_date, :plan_time]},
      :update => {:sync_plan => [:description, :name, :interval, :date, :time]},
    }
  end

  def create
    sdate = params[:sync_plan].delete :plan_date
    stime = params[:sync_plan].delete :plan_time
    params[:sync_plan][:sync_date] = convert_date_time(sdate, stime)
    return render_bad_parameters(_('Invalid date or time format')) unless params[:sync_plan][:sync_date]

    @plan = SyncPlan.create! params[:sync_plan].merge({:organization => current_organization})
    notify.success N_("Sync Plan '%s' was created.") % @plan['name']

    if search_validate(SyncPlan, @plan.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@plan, :accessor=>"id", :columns=>['name', 'interval'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @plan["name"]
      render :json => { :no_match => true }
    end
  end

  protected

  def get_plan
    @plan = SyncPlan.find(params[:id])
  end

  def controller_display_name
    return 'sync_plan'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
