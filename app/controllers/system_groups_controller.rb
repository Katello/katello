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

  before_filter :panel_options, :only=>[:index, :items, :create, :copy]
  before_filter :find_group, :only=>[:edit, :update, :destroy, :destroy_systems, :systems, :lock,
                                     :show, :add_systems, :remove_systems, :copy]
  before_filter :authorize
  def rules
    any_readable = lambda{current_organization && SystemGroup.any_readable?(current_organization)}
    read_perm = lambda{@group.readable?}
    edit_perm = lambda{@group.editable?}
    create_perm = lambda{SystemGroup.creatable?(current_organization)}
    destroy_perm = lambda{@group.deletable?}
    destroy_systems_perm = lambda{@group.systems_deletable?}
    lock_perm = lambda{@group.locking?}
    {
        :index=>any_readable,
        :items=>any_readable,
        :new => create_perm,
        :create=>create_perm,
        :copy=>create_perm,
        :edit=>read_perm,
        :systems => read_perm,
        :update=>edit_perm,
        :destroy=>destroy_perm,
        :destroy_systems=>destroy_systems_perm,
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
       :create => {:system_group => [:name, :description, :max_systems]},
       :update => {:system_group => [:name, :description, :max_systems, :locked]},
       :add_systems => [:system_ids, :id],
       :remove_systems => [:system_ids, :id]
     }
  end

  def section_id
    'systems'
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
    notice _("System Group %s created successfully.") % @group.name
    if !search_validate(SystemGroup, @group.id, params[:search])
      notice _("'%s' did not meet the current search criteria and is not being shown.") % @group.name,
             { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    else
      respond_to do |format|
        format.html {render :partial=>"common/list_item",
                     :locals=>{:item=>@group, :initial_action=>@panel_options[:initial_action],
                     :accessor=>"id", :columns=>@panel_options[:col], :name=>controller_display_name}}
        format.json {render :json => @group}
      end
    end

  rescue Exception=> e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def copy
    new_group = SystemGroup.new
    new_group.name = params[:name]
    new_group.description = params[:description]
    new_group.organization = @group.organization
    new_group.max_systems = @group.max_systems
    new_group.save!

    new_group.systems = @group.systems
    new_group.save!

    notice _("System Group %{c} created successfully as a copy of system group %{s}.") % {:c => new_group.name, :s =>@group.name}

    render :partial=>"common/list_item", :locals=>{:item=>new_group, :initial_action=>@panel_options[:initial_action],
                                                   :accessor=>"id", :columns=>@panel_options[:col],
                                                   :name=>controller_display_name}

  rescue Exception=> e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:filter => @group, :name=>controller_display_name,
                                                                       :editable=>@group.editable?
                                                                       }
  end

  def show
    render :partial => "system_groups/list_group", :locals=>{:item=>@group, :accessor=>"id", :name=>controller_display_name}
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
    elsif options[:max_systems]
      @group.max_systems = options[:max_systems]
      to_ret = @group.max_systems
    end

    @group.save!
    notice _("System Group %s has been updated.") % @group.name

    if not search_validate(SystemGroup, @group.id, params[:search])
      notice _("'%s' no longer matches the current search criteria.") % @group["name"], { :level => :message, :synchronous_request => true }
    end

    render :text=>to_ret
  rescue Exception=>e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def lock
    @group.locked = params[:system_group][:locked] == 'true'
    @group.save!
    notice _("System Group %s has been updated.") % @group.name
    render :text=>""
  end

  def destroy
    @group.destroy
    notice _("System Group %s deleted.") % @group.name
    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
  rescue Exception => e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def destroy_systems
    # this will destroy both the systems contained within the group as well as the group itself
    system_names = []
    @group.systems.each do |system|
      system_names.push(system.name)
      system.destroy
    end
    @group.destroy

    notice((_("Deleted System Group %{s} and it's %{n} systems.") % {:s => @group.name, :n =>system_names.length.to_s}),
           {:details => system_names.join("\n")})

    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}

  rescue Exception => e
    notice e, {:level => :error}
    render :text=>e, :status=>500
  end

  def items
    ids = SystemGroup.readable(current_organization).collect{|s| s.id}
    render_panel_direct(SystemGroup, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
      {:default_field => :name, :load=>true, :filter=>[{:id=>ids},{:organization_id=>[current_organization.id]}]})
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
        :list_partial => 'system_groups/list_groups',
        :ajax_load=>true,
        :search_class=>SystemGroup
    }
  end

  def systems
    @system_joins = @group.system_system_groups.sort_by{|a| a.system.name}
    render :partial => "systems", :layout => "tupane_layout",
           :locals => {:filter => @group, :name=>controller_display_name, :editable=>@group.editable?,
                       :systems_deletable=>@group.systems_deletable?}
  end

  def add_systems
    ids = params[:system_ids].collect{|s| s.to_i} - @group.system_ids #ignore dups
    systems = System.readable(current_organization).where(:id=>ids)
    @group.system_ids = (@group.system_ids + systems.collect{|s| s.id}).uniq
    @group.save!
    system_joins = @group.system_system_groups.where(:system_id=>ids)
    render :partial=>'system_item', :collection=>system_joins, :as=>:system,
           :locals=>{:editable=>@group.editable?}
  end

  def remove_systems
    systems = System.readable(current_organization).where(:id=>params[:system_ids]).collect{|s| s.id}
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
      filter :terms, {:id=>SystemGroup.editable(org).collect{|g| g.id}}
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
