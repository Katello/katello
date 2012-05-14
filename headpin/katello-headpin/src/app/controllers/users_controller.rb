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

class UsersController < ApplicationController
  include AutoCompleteSearch

  def section_id
    'operations'
  end

  before_filter :setup_options, :only => [:items, :index]
  before_filter :find_user, :only => [:items, :index, :edit, :edit_environment, :update_environment, :update_preference,
                                      :update, :update_roles, :update_locale, :clear_helptips, :destroy]
  before_filter :authorize
  skip_before_filter :require_org

  def rules
    index_test  = lambda { true }
    create_test = lambda { User.creatable? }

    read_test               = lambda { @user.id == current_user.id || @user.readable? }
    edit_test               = lambda { can_edit_user? }
    delete_test             = lambda { @user.deletable? }
    edit_details_test       = lambda { can_edit_user? }
    update_environment_test = lambda do
      if @user.id == current_user.id
        env_id = params['env_id'] ? params['env_id']['env_id'].to_i : nil
        if env_id
          KTEnvironment.find(env_id).systems_registerable?
        else
          true # No env means removing previous default env
        end
      else
        @user.editable?
      end
    end


    user_helptip = lambda { true } #everyone can enable disable a helptip

    { :index                => index_test,
      :items                => index_test,
      :auto_complete_search => index_test,
      :new                  => create_test,
      :create               => create_test,
      :edit                 => read_test,
      :account              => read_test,
      :edit_environment     => read_test,
      :update_environment   => update_environment_test,
      :update               => edit_details_test,
      :update_roles         => edit_test,
      :update_locale        => edit_test,
      :update_preference    => edit_test,
      :clear_helptips       => edit_details_test,
      :destroy              => delete_test,
      :enable_helptip       => user_helptip,
      :disable_helptip      => user_helptip,
    }
  end

  def param_rules
    { :create       => { :user => [:password, :username, :env_id, :email] },
      :update       => { :user => [:password, :env_id, :email, :helptips_enabled] },
      :update_roles => { :user => [:role_ids] }
    }
  end


  # Render list of users. Note that if the current user does not have permission
  # to view all users, the results are restricted to just themselves.
  def items
    if !params[:only] && User.any_readable?
      render_panel_direct(User, @panel_options, params[:search], params[:offset], [:username_sort, 'asc'],
                          { :default_field => :username,
                            :filter        => [{ :hidden => [false] }] })
    else
      users = [@user]
      render_panel_items(users, @panel_options, nil, params[:offset])
    end
  end

  def edit
    accessible_envs = []
    if current_organization
      @organization   = current_organization
      accessible_envs = current_organization.environments
      setup_environment_selector(current_organization, accessible_envs)
      @environment = first_env_in_path(accessible_envs)
    end
    render :partial => "edit", :layout => "tupane_layout",
           :locals  => { :user            => @user,
                         :editable        => can_edit_user?,
                         :name            => controller_display_name,
                         :accessible_envs => accessible_envs,
                         :ldap            => ldap_enabled? }
  end

  def new
    @user         = User.new
    @organization = nil
    render :partial => "new", :layout => "tupane_layout", :locals => { :user => @user, :accessible_envs => nil }
  end

  def create
    # Pulp quietly ignored unkonwn attributes; Headpin needs to remove
    default_environment_id = params[:user].delete(:env_id)
    @user = User.new(params[:user])

    if default_environment_id
      @environment  = KTEnvironment.find(default_environment_id)
      @organization = @environment.organization
      @user.save!
      @user.default_environment = @environment
    else
      # user selected an org that has no environments defined
      raise no_env_available_msg unless params['org_id']['org_id'].blank?

      # user selected 'No Default Organization'
      @environment  = nil
      @organization = nil
      @user.save!
    end

    notice @user.username + _(" created successfully.")
    if search_validate(User, user.id, params[:search])
      render :partial => "common/list_item",
             :locals  => { :item => @user, :accessor => "id", :columns => ["username"], :name => controller_display_name }
    else
      notice _("'%s' did not meet the current search criteria and is not being shown.") % @user["name"],
             { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    end
  rescue ActiveRecord::RecordNotSaved => error
    notice error, { :level => :error }
    #transaction, if something goes wrong with the creation of the permission, we will need to delete the user
    @user.destroy unless @user.new_record?
    render :json => @user.errors, :status => :bad_request
  end

  def update
    params[:user].delete :username

    if @user.update_attributes(params[:user])
      notice _("User updated successfully.")
      attr = params[:user].first.last if params[:user].first
      attr ||= ""

      if not search_validate(User, user.id, params[:search])
        notice _("'%s' no longer matches the current search criteria.") % @user["name"],
               { :level => 'message', :synchronous_request => false }
      end

      render :text => attr and return
    end
    notice "", { :level => :error, :list_items => @user.errors.to_a }
    render :text => @user.errors, :status => :ok
  end

  def update_locale
    locale = params[:locale][:locale]
    if AppConfig.available_locales.include? locale
      @user.default_locale = locale
      I18n.locale          = locale
    else
      @user.default_locale = nil
    end
    @user.save!
    notice _("User updated successfully.")
    redirect_to "#{users_path(:id => @user)}#panel=user_#{@user.id}"
  end

  def update_preference
    preference = params[:preference]
    if preference
      @user.preferences[:user] = { } unless @user.preferences.has_key? :user
      if params[:value] == "true"
        value = true
      elsif  params[:value] == "false"
        value = false
      else
        value = params[:value]
      end
      @user.preferences[:user][preference.to_sym] = value
      @user.save!
    end

    respond_to do |format|
      format.html { render :text => params[:preference] }
      format.js
    end
  end

  def edit_environment
    if @user.has_default_environment?
      @old_perm     = @user.default_systems_reg_permission
      @environment  = @user.default_environment
      @old_env      = @environment
      @organization = Organization.find(@environment.attributes['organization_id'])

      accessible_envs = if current_user.id == @user.id
                          KTEnvironment.systems_registerable(@organization)
                        else
                          KTEnvironment.where(:organization_id => @organization.id)
                        end
      setup_environment_selector(@organization, accessible_envs)
    else
      @organization   = nil
      accessible_envs = nil
    end

    render :partial => "edit_environment", :layout => "tupane_layout",
           :locals  => { :user            => @user,
                         :editable        => can_edit_user?,
                         :name            => controller_display_name,
                         :accessible_envs => accessible_envs }
  end

  def update_environment
    default_environment_id = params['env_id'].try(:[], 'env_id').try(:to_i)

    if @user.default_environment.try(:id) == default_environment_id
      err_msg = N_("The default you supplied was the same as the old default.")
      notice err_msg, { :level => :error }
      render(:text => err_msg, :status => 400) and return
    end

    raise no_env_available_msg if default_environment_id.nil? && params['org_id'].present?

    @environment              = default_environment_id.nil? ? nil : KTEnvironment.find(default_environment_id)
    @user.default_environment = @environment
    #@user.save!

    @organization             = @environment.try :organization

    notice _("User environment updated successfully.")

    if @organization && @environment
      render :json => { :org => @organization.name, :env => @environment.name } and return
    end
    render :json => { :org => _("No default set for this user."), :env => _("No default set for this user.") } and return

  rescue ActiveRecord::RecordNotSaved => error
    notice error.message, { :level => :error }
    render :text => error.message, :status => 400
  end

  def update_roles
    params[:user] = { "role_ids" => [] } unless params.has_key? :user

    #Add in the own role if updating roles, cause the user shouldn't see his own role
    params[:user][:role_ids] << @user.own_role.id

    if  @user.update_attributes(params[:user])
      notice _("User updated successfully.")

      if not search_validate(User, user.id, params[:search])
        notice _("'%s' no longer matches the current search criteria.") % @user["name"], { :level => 'message', :synchronous_request => false }
      end

      render :nothing => true and return
    end
    notice "", { :level => :error, :list_items => @user.errors.to_a }
    render :text => @user.errors, :status => :ok
  end

  def destroy
    @id = params[:id]
    #remove the user
    @user.destroy
    if @user.destroyed?
      notice _("User '%s' was deleted.") % @user[:username]
      #render and do the removal in one swoop!
      render :partial => "common/list_remove", :locals => { :id => @id, :name => controller_display_name } and return
    end
    notice "", { :level => :error, :list_items => @user.errors.to_a }
    render :text => @user.errors, :status => :ok
  rescue Exception => error
    notice "", { :level => :error, :list_items => @user.errors.to_a }
    render :json => @user.errors, :status => :bad_request
  end

  def clear_helptips
    @user.clear_helptips
    notice _("Disabled help tips have been re-enabled.")
    render :text => _("Cleared")
  end

  def enable_helptip
    current_user.enable_helptip params[:key]
    render :text => ""
  end

  def disable_helptip
    current_user.disable_helptip params[:key]
    render :text => ""
  end

  def can_edit_user?
    @user && (current_user.id == @user.id || @user.editable?)
  end

  def ldap_enabled?
    AppConfig.warden == 'ldap'
  end

  private

  def find_user
    if User.any_readable?
      @user = User.find params[:id] if params[:id]
    else
      @user = current_user
    end
  end


  def setup_options
    @panel_options = { :title         => _('Users'),
                       :col           => ['username'],
                       :titles        => [_('Username')],
                       :create        => _('User'),
                       :name          => controller_display_name,
                       :ajax_load     => true,
                       :ajax_scroll   => items_users_path(),
                       :enable_create => User.creatable?,
                       :search_class  => User }
  end

  def controller_display_name
    return 'user'
  end

end
