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
  before_filter :find_group, :only=>[:edit, :update, :destroy, :systems, :lock,
                                     :show, :add_systems, :remove_systems]
  before_filter :authorize
  def rules
    any_readable = lambda{current_organization && SystemGroup.any_readable?(current_organization)}
    read_perm = lambda{@group.readable?}
    edit_perm = lambda{@group.editable?}
    create_perm = lambda{SystemGroup.creatable?(current_organization)}
    destroy_perm = lambda{@group.deletable?}
    lock_perm = lambda{@group.locking?}
    {
        :index=>any_readable,
        :items=>any_readable,
        :new => create_perm,
        :create=>create_perm,
        :edit=>read_perm,
        :systems => read_perm,
        :update=>edit_perm,
        :destroy=>destroy_perm,
        :show=>read_perm,
        :auto_complete=>any_readable,
        :add_systems=> edit_perm,
        :remove_systems=>edit_perm,
        :validate_name=>any_readable,
        :lock=>lock_perm,
        :unlock=>lock_perm
    }

  end

  def param_rules
     {
       :create => {:system_group => [:name, :description]},
       :update => {:system_group => [:name, :description, :locked]},
       :add_systems => [:system_ids, :id],
       :remove_systems => [:system_ids, :id]
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


  def lock
    @group.locked = params[:system_group][:lock] == 'true'
    @group.save!
    notice _("Package Filter '%s' has been updated.") % @group.name
    render :text=>""
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
    ids = SystemGroup.readable(current_organization).collect{|s| s.id}
    render_panel_direct(SystemGroup, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
      {:default_field => :name, :filter=>[{:id=>ids},{:organization_id=>[current_organization.id]}]})
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
        :initial_action=>:systems,
        :ajax_load=>true,
        :search_class=>Filter
    }
  end

  def systems
    @systems = @group.systems.sort_by{|a| a.name}
    render :partial => "systems", :layout => "tupane_layout",
           :locals => {:filter => @group, :editable=>@group.editable?,
                                :name=>controller_display_name}
  end

  def add_systems
    ids = params[:system_ids].collect{|s| s.to_i} - @group.system_ids #ignore dups
    @systems = System.where(:id=>ids)
    @group.system_ids = (@group.system_ids + @systems.collect{|s| s.id}).uniq
    @group.save!
    render :partial=>'system_item', :collection=>@systems, :as=>:system,
           :locals=>{:editable=>@group.editable?}
  end

  def remove_systems
    systems = System.where(:id=>params[:system_ids]).collect{|s| s.id}
    @group.system_ids = (@group.system_ids - systems).uniq
    @group.save!
    render :text=>''
  end

  def auto_complete
    query = "name_autocomplete:#{params[:term]}"
    org = current_organization

    groups = SystemGroup.search do
      query do
        string query
      end
      filter :term, {:organization_id => org.id}
      filter :term, {:locked=>false}
    end
    render :json=>groups.map{|s| {:label=>s.name, :value=>s.name, :id=>s.id}}
  end

  def controller_display_name
    return 'system_group'
  end

  def validate_name
    name = params[:term]
    render :json=>SystemGroup.search("name:#{name}").count
  end

  def find_group
    @group = SystemGroup.find(params[:id])
  end

end
