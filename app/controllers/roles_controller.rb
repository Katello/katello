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

class RolesController < ApplicationController

  before_filter :find_role, :except => [:index, :items, :new, :create]
  before_filter :authorize #call authorize after find_role so we call auth based on the id instead of cp_id

  before_filter :setup_resource_types, :only =>[:edit, :update, :update_permission, :show_permission, :create_permission]
  before_filter :setup_options, :only => [:index, :items]
  include AutoCompleteSearch
  
  def rules
    index_check = lambda{Role.any_readable?}
    create_check = lambda{Role.creatable?}
    read_check = lambda{@role.readable?}
    edit_check = lambda{@role.editable?}
    delete_check = lambda{@role.deletable?}
    {
      :index => index_check,
      :items => index_check,
      :create => create_check,
      :new => create_check,
      :edit => read_check,
      :verbs_and_scopes => read_check,
      :show_permission => read_check,
      :update => edit_check,
      :create_permission => edit_check,
      :update_permission=> edit_check,
      :delete => delete_check,
      }
  end

  def section_id
     'operations'
   end

  def index
    begin
      # retrieve only non-self roles... permissions on a self-role will be handled 
      # as part of the user
      @roles = Role.search_for(params[:search]).non_self.limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @roles = Role.search_for ''
    end
  end
  
  def items
    start = params[:offset]
    @roles = Role.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @roles, @panel_options
  end
  
  def setup_options
    @panel_options = { :title => _('Roles'),
                 :col => ['name'],
                 :create => _('Role'),
                 :name => _('role'),
                 :ajax_scroll => items_roles_path()}
  end
  
  def new
    @role = Role.new
    render :partial=>"new", :layout => "tupane_layout", :locals=>{:role=>@role}
  end

  def edit
    # render the appropriate partial depending on whether or not the role is a self role
    @user = @role.self_role_for_user
    if @user.nil?
      render :partial=>"edit", :layout => "tupane_layout", :locals=>{:role=>@role}
    else
      render :partial=>"self_role_edit", :layout => "tupane_layout", :locals=>{:role=>@role}
    end
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      notice @role.name + " " + _("Role created.")
      #render :json=>@role
      render :partial=>"common/list_item", :locals=>{:item=>@role, :accessor=>"id", :columns=>["name"]}
    else
      errors "", {:list_items => @role.errors.to_a}
      render :json=>@role.errors, :status=>:bad_request
    end
  end

  def update
    return if @role.name == "admin"
    if @role.update_attributes(params[:role])
      notice _("Role updated.")
      render :text=>params[:role].first[1]
    else
      errors "", {:list_items => @role.errors.to_a}
      respond_to do |format|
        format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def destroy
    @id = params[:id]
    begin
      #remove the user
      @role.destroy
      if @role.destroyed?
        notice _("Role '#{@role[:name]}' was deleted.")
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id => @id}
      else
        raise
      end
    rescue Exception => error
      errors error.to_s
      render :text=> error.to_s, :status=>:bad_request and return
    end
  end

  def verbs_and_scopes
    verbs = Verb.verbs_for(params[:resource_type]).collect {|name, display_name| VirtualTag.new(name, display_name)}
    verbs.sort! {|a,b| a.display_name <=> b.display_name}
    scopes = Tag.tags_for(params[:resource_type]).collect { |t| VirtualTag.new(t.name, t.display_name) }

    render :json=> {:verbs => verbs, :scopes => scopes}
  end

  def update_permission
    @permission = Permission.find(params[:permission_id])
    @permission.update_attributes(params[:permission])
    notice _("Permission updated.")
    render :partial => "permission", :locals =>{:perm => @permission, :role=>@role, :data_new=> false}
  end

  def create_permission
    new_params = {:role => @role}
    new_params.merge! params[:permission]
    @perm = Permission.create! new_params
    notice _("Permission created.")
    render :partial => "permission", :locals =>{:perm => @perm, :role=>@role, :data_new=> false}
  end

  def show_permission
    if params[:perm_id].nil?
      permission = Permission.new(:role=> role, :resource_type => ResourceType.new)
    else
      permission = Permission.find(params[:perm_id])
    end
    render :partial=>"permission", :locals=>{:perm=>permission, :role=>role, :data_new=>permission.new_record?}

  end


  private
  def find_role
    @role =  Role.find(params[:role_id]) if params.has_key? :role_id
    @role =  Role.find(params[:id]) unless params.has_key? :role_id
  end

  def setup_resource_types
    @resource_types = {}
    ResourceType::TYPES.each do |res, details|
      @resource_types[res] = details[:name]
    end
  end
  
end
