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

  before_filter :find_role, :except => [:index, :items, :new, :create, :verbs_and_scopes]
  before_filter :authorize #call authorize after find_role so we call auth based on the id instead of cp_id
  skip_before_filter :require_org
  before_filter :setup_options, :only => [:index, :items]
  helper_method :resource_types

  include AutoCompleteSearch
  include BreadcrumbHelper
  include BreadcrumbHelper::RolesBreadcrumbs
  
  def rules
    index_check = lambda{Role.any_readable?}
    create_check = lambda{Role.creatable?}
    read_check = lambda{@role.readable?}
    edit_check = lambda{@role.editable?}
    delete_check = lambda{@role.deletable?}
    {
      :index => index_check,
      :items => index_check,
      :verbs_and_scopes => index_check,
        
      :create => create_check,
      :new => create_check,
      :edit => read_check,
      :show_permission => read_check,
      :update => edit_check,
      :create_permission => edit_check,
      :update_permission=> edit_check,
      :destroy_permission => edit_check,
      :destroy => delete_check,
      }
  end

  def section_id
     'operations'
   end

  def index
    begin
      # retrieve only non-self roles... permissions on a self-role will be handled 
      # as part of the user
      @roles = Role.readable.search_for(params[:search]).non_self.limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @roles = Role.search_for ''
    end
  end
  
  def items
    start = params[:offset]
    @roles = Role.readable.search_for(params[:search]).limit(current_user.page_size).offset(start)
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
    @organizations = Organization.all

    # render the appropriate partial depending on whether or not the role is a self role
    @user = @role.self_role_for_user
    if @user.nil?
      render :partial=>"edit", :layout => "tupane_layout", :locals=>{:role=>@role, :resource_types => resource_types }
    else
      render :partial=>"self_role_edit", :layout => "tupane_layout", :locals=>{:role=>@role, :editable=>@user.editable?}
    end
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      notice @role.name + " " + _("Role created.")
      render :partial=>"common/list_item", :locals=>{:item=>@role, :accessor=>"id", :columns=>["name"]}
    else
      errors "", {:list_items => @role.errors.to_a}
      render :json=>@role.errors, :status=>:bad_request
    end
  end

  def update
    return if @role.name == "admin"
    
    if params[:update_users]
      if params[:update_users][:adding] == "true"
        @role.users << User.find(params[:update_users][:user_id])
        @role.save!
      else
        @role.users.delete(User.find(params[:update_users][:user_id]))
        @role.save!
      end
      render :json => params[:update_users]
    elsif @role.update_attributes(params[:role])
      notice _("Role updated.")
      render :json=>params[:role]
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
    details= {}
    
    resource_types.each do |type, value|
      details[type] = {}
      details[type][:verbs] = Verb.verbs_for(type, false).collect {|name, display_name| VirtualTag.new(name, display_name)}
      details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
      details[type][:tags] = Tag.tags_for(type, params[:organization_id]).collect { |t| VirtualTag.new(t.name, t.display_name) }
      details[type][:global] = value["global"]
      details[type][:name] = value["name"]
    end
    
    render :json => details
  end

  def update_permission
    @permission = Permission.find(params[:permission_id])
    @permission.update_attributes(params[:permission])
    notice _("Permission updated.")
    render :partial => "permission", :locals =>{:perm => @permission, :role=>@role, :data_new=> false}
  end

  def create_permission
    new_params = {:role => @role}
    type_name = params[:permission][:resource_type_attributes][:name]
    
    if type_name == "all"
      new_params[:all_tags] = true
      new_params[:all_verbs] = true
    end
    
    new_params[:resource_type] = ResourceType.find_or_create_by_name(:name=>type_name)
    new_params.merge! params[:permission]
    @perm = Permission.create! new_params
    to_return = {}
    add_permission_bc(to_return, @perm, false)
    notice _("Permission created.")
    render :json => to_return
  end

  def show_permission
    if params[:perm_id].nil?
      permission = Permission.new(:role=> @role, :resource_type => ResourceType.new)
    else
      permission = Permission.find(params[:perm_id])
    end
    render :partial=>"permission", :locals=>{:perm=>permission, :role=>@role, :data_new=>permission.new_record?}
  end

  def destroy_permission
    permission = Permission.find(params[:permission_id])
    permission.destroy
    notice _("Permission removed.")
    render :json => params[:permission_id]
  end

  private
  def find_role
    @role =  Role.find(params[:role_id]) if params.has_key? :role_id
    @role =  Role.find(params[:id]) unless params.has_key? :role_id
  rescue Exception => error
    render :text=>errors.to_s, :status=>:bad_request and return false
  end

  def resource_types
    ResourceType::TYPES
  end

end
