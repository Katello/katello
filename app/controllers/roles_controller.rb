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

class RolesController < ApplicationController

  before_filter :find_role, :except => [:index, :items, :new, :create, :verbs_and_scopes, :auto_complete_search, :create_ldap_group, :destroy_ldap_group]
  before_filter :authorize #call authorize after find_role so we call auth based on the id instead of cp_id
  skip_before_filter :require_org
  before_filter :setup_options, :only => [:index, :items]
  helper_method :resource_types

  include AutoCompleteSearch
  include BreadcrumbHelper
  include RolesBreadcrumbs

  def rules
    create_check = lambda{Role.creatable?}
    read_check = lambda{(@role && @role.self_role_for_user && @role.self_role_for_user.id == current_user.id) || Role.any_readable?}
    edit_check = lambda{Role.editable?}
    delete_check = lambda{Role.deletable?}
    {
      :index => read_check,
      :items => read_check,
      :verbs_and_scopes => read_check,
      :auto_complete_search => read_check,

      :create => create_check,
      :new => create_check,
      :edit => read_check,
      :show_permission => read_check,
      :update => edit_check,
      :create_permission => edit_check,
      :update_permission=> edit_check,
      :destroy_permission => edit_check,
      :destroy => delete_check,
      :create_ldap_group => edit_check,
      :destroy_ldap_group => edit_check,
      }
  end

  def param_rules
    perm_check = lambda do
      if params[:permission]
        perm_attrs = {:permission => [:organization_id, :verb_values, :tag_values, :name, :resource_type_attributes,
                                                        :all_tags, :all_verbs, :description]}

        diff = check_hash_params(perm_attrs, params)
        return diff unless diff.empty?

        if params[:permission][:resource_type_attributes]
          return check_hash_params({:resource_type_attributes => [:name]}, params[:permission])
        end
      end
      []
    end

     {
       :create => {:role => [:name, :description]},
       :update => {:role => [:name, :description], :update_users => [:user_id,:adding]},
       :create_permission => perm_check,
       :update_permission => perm_check,
       :create_ldap_group => [:group, :role_id],
       :destroy_ldap_group => [:id, :role_id],
     }
  end


  def section_id
     'operations'
  end

  def menu_definition
    {:index => :admin_menu}.with_indifferent_access
  end

  def items
    render_panel_direct(Role, @panel_options,  params[:search], params[:offset], [:name_sort, :asc],
                        {:default_field => :name, :filter=>[{:self_role=>[false]}], :load=>true})
  end

  def setup_options
    @panel_options = { :title => _('Roles'),
                 :col => ['name'],
                 :titles => [_('Name')],
                 :create => _('Role'),
                 :create_label => _('+ New Role'),
                 :name => controller_display_name,
                 :ajax_load  => true,
                 :list_partial => 'roles/list_roles',
                 :ajax_scroll => items_roles_path(),
                 :enable_create=> Role.creatable?,
                 :search_class=>Role}
  end

  def new
    @role = Role.new
    render :partial=>"new", :locals=>{:role=>@role}
  end

  def edit
    @organizations = Organization.all

    # render the appropriate partial depending on whether or not the role is a self role
    @user = @role.self_role_for_user
    if @user.nil?
      render :partial=>"edit", :locals=>{:role=>@role, :resource_types => resource_types }
    else
      render :partial=>"self_role_edit", :locals=>{:role=>@role, :editable=>@user.editable?}
    end
  end

  def create
    @role = Role.create!(params[:role])
    notify.success _("Role '%s' was created.") % @role.name

    if search_validate(Role, @role.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@role, :accessor=>"id", :columns=>["name"], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @role["name"]
      render :json => { :no_match => true }
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
    else
      @role.update_attributes!(params[:role])
      notify.success _("Role '%s' was updated.") % @role.name

      if !search_validate(Role, @role.id, params[:search])
        notify.message _("'%s' no longer matches the current search criteria.") % @role["name"],
                       :asynchronous => false
      end
      render :json=>params[:role]
    end
  end

  def destroy
    #remove the user
    if @role.destroy
      notify.success _("Role '%s' was deleted.") % @role[:name]
      #render and do the removal in one swoop!
      render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
    end
  end

  def verbs_and_scopes
    details= {}

    resource_types.each do |type, value|
      if !value["global"]
        details[type] = {}
        details[type][:verbs] = Verb.verbs_for(type, false).collect {|name, display_name| VirtualTag.new(name, display_name)}
        details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
        details[type][:tags] = Tag.tags_for(type, params[:organization_id]).collect { |t| VirtualTag.new(t.name, t.display_name) }
        details[type][:no_tag_verbs] = Verb.no_tag_verbs(type)
        details[type][:global] = value["global"]
        details[type][:name] = value["name"]
      end
    end
    render :json => details
  end

  def update_permission
    attributes = params[:permission]
    @permission = Permission.find(params[:permission_id])

    if attributes.has_key?(:tag_names) && @permission.all_tags
      @permission.all_tags = false
    end

    if attributes.has_key?(:verb_values) && @permission.all_verbs
      @permission.all_verbs = false
    end

    if attributes.has_key?(:all_verbs)
      @permission.verbs.each do |verb|
        @permission.verbs.delete(Verb.find_or_create_by_verb(verb.name))
      end
    end

    if attributes.has_key?(:all_tags)
      @permission.tags.each do |tag|
        @permission.tags.delete(tag)
      end
    end

    @permission.update_attributes!(params[:permission])
    to_return = { :type => @permission.resource_type.name }
    add_permission_bc(to_return, @permission, false)
    notify.success _("Permission '%s' was updated.") % @permission.name
    render :json => to_return
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
    to_return = { :type => @perm.resource_type.name }
    add_permission_bc(to_return, @perm, false)
    notify.success _("Permission '%s' was created.") % @perm.name
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
    notify.success _("Permission '%s' was removed.") % permission.name
    render :json => params[:permission_id]
  end

  def create_ldap_group
    group_hash = { :role_id => params[:role_id], :ldap_group => params[:group] }
    @group = LdapGroupRole.create!(group_hash)
    to_return = { :group => @group.ldap_group }
    add_group_to_bc(to_return, @group)
    notify.success _("LDAP Group '%s' was created.") % @group.ldap_group
    render :json => to_return
  end

  def destroy_ldap_group
    group = LdapGroupRole.find(params[:id])
    name = group.ldap_group
    group.destroy
    notify.success _("LDAP Group Mapping for '%s' was removed.") % name
    render :json => params[:id]
  end

  private

  def find_role
    @role =  Role.find(params[:role_id] || params[:id])
  end

  def resource_types
    ResourceType::TYPES
  end

  def controller_display_name
    return 'role'
  end

  def default_notify_options
    super.merge :organization => nil
  end


end
