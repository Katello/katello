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

class SystemGroupsController < ApplicationController


  before_filter :panel_options, :only=>[:index, :items, :create]
  before_filter :find_group, :only=>[:edit, :update, :destroy, :show]

  def rules
    read = lambda{true}
    edit = lambda{true}
    create = lambda{true}
    {
        :index=>read,
        :items=>read,
        :new => create,
        :create=>create,
        :edit=>read,
        :update=>edit,
        :destroy=>edit,
        :show=>read,
    }

  end

  def param_rules
     {
       :create => {:system_group => [:name, :description]},
       :update => {:system_group => [:name, :description]}
     }
  end



  def index
    render "index"
  end

  def new
    @group = SystemGroup.new
    render :partial => 'new', :layout => 'tupane_layout'
  end

  def create
    @group = SystemGroup.create!(params[:system_group].merge({:organization_id=>current_organization.id}))
    notice N_("System Group %s created successfully.") % @group.name
    if !search_validate(SystemGroup, @group.id, params[:search])
      notice _("'%s' did not meet the current search criteria and is not being shown.") % @group.name,
             { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    else
      render :partial=>"common/list_item",
             :locals=>{:item=>@group, :initial_action=>@panel_options[:initial_action],
                   :accessor=>"id", :columns=>@panel_options[:col], :name=>controller_display_name}
    end

  rescue Exception=> e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end


  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:filter => @group, :editable=>@group.editable?,
                                                                       :name=>controller_display_name}
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@group, :accessor=>"id", :columns=>['name']}
  end

  def update
    options = params[:system_group]
    to_ret = ""
    if options[:name]
      @group.name = options[:name]
      to_ret =  @group.name
    elsif options[:description]
      @group.description = options[:description]
      to_ret = @group.description
    end

    @group.save!
    notice _("Package Filter '%s' has been updated.") % @group.name

    if not search_validate(SystemGroup, @group.id, params[:search])
      notice _("'%s' no longer matches the current search criteria.") % @group["name"], { :level => :message, :synchronous_request => true }
    end

    render :text=>to_ret
  rescue Exception=>e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def destroy
    @group.destroy
    notice _("System Group  %s deleted.") % @group.name
    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
  rescue Exception => e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def items
    render_panel_direct(SystemGroup, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
      {:default_field => :name, :filter=>{:organization_id=>[current_organization.id]}})
  end

  def panel_options
    @panel_options = {
        :title => _('System Groups'),
        :col => ['name'],
        :titles => [_('Name')],
        :create => _('System Group'),
        :name => controller_display_name,
        :ajax_scroll=>items_system_groups_path(),
        :enable_create=> SystemGroup.creatable?(current_organization),
        :initial_action=>:edit,
        :ajax_load=>true,
        :search_class=>Filter
    }
  end

  def controller_display_name
    return 'system_group'
  end

  def find_group
    @group = SystemGroup.find(params[:id])
  end

end
