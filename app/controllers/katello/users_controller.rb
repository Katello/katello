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

module Katello
class UsersController < ApplicationController
  include AutoCompleteSearch

  def section_id
    'operations'
  end

  def menu_definition
    {:index => :admin_menu}.with_indifferent_access
  end

  before_filter :setup_options, :only => [:items, :index]
  before_filter :find_user, :only => [:items, :index, :edit, :edit_environment, :update_environment, :update_preference,
                                      :update, :update_roles, :update_locale, :clear_helptips, :setup_default_org, :destroy]
  before_filter :authorize
  skip_before_filter :require_org

  # TODO: break up method
  # rubocop:disable MethodLength
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
      :setup_default_org    => edit_test
    }
  end

  def param_rules
    { :create       => { :user => [:login, :env_id, :mail] },
      :update       => { :user => [:env_id, :mail, :helptips_enabled, :legacy_mode] },
      :update_roles => { :user => [:role_ids] }
    }
  end

  # Render list of users. Note that if the current user does not have permission
  # to view all users, the results are restricted to just themselves.
  def items
    if !params[:only] && User.any_readable?
      render_panel_direct(User, @panel_options, params[:search], params[:offset], [:login_sort, 'asc'],
                          { :default_field => :login,
                            :filter        => [{ :hidden => [false] }] })
    else
      users = [@user]
      render_panel_items(users, @panel_options, nil, "0")
    end
  end

  def edit
    accessible_envs = []
    if current_organization
      @organization   = current_organization
      accessible_envs = current_organization.environments
      setup_environment_selector(current_organization, accessible_envs)
      @environment = first_env_in_path(accessible_envs, true)
    end
    render :partial => "edit",
           :locals  => { :user            => @user,
                         :editable        => can_edit_user?,
                         :name            => controller_display_name,
                         :accessible_envs => accessible_envs,
                         :ldap            => ldap_enabled? }
  end

  def new
    @user         = User.new
    @organization = nil
    @ldap = Katello.config.warden == 'ldap'
    render :partial => "new", :locals => { :user => @user, :accessible_envs => nil }
  end

  # TODO: break up method
  # rubocop:disable MethodLength
  def create
    if Katello.config.katello?
      # Pulp quietly ignored unkonwn attributes; Headpin needs to remove
      default_environment_id = params[:user].delete(:env_id)
    else
      default_environment_id = nil
      if !params['org_id']['org_id'].blank?
        @organization = Organization.find_by_id(params['org_id']['org_id'].try(:to_i))
        default_environment_id = @organization.library.id
      end
    end
    @user = User.new(params[:user])

    if default_environment_id
      @environment  = KTEnvironment.find(default_environment_id)
      @organization = @environment.organization
      @user.default_environment = @environment
      @user.save!
    else
      # user selected an org that has no environments defined
      fail no_env_available_msg unless params['org_id']['org_id'].blank?

      # user selected 'No Default Organization'
      @environment  = nil
      @organization = nil
      @user.save!
    end

    notify.success @user.login + _(" created successfully.")
    if search_validate(User, @user.id, params[:search], :login)
      render :partial => "katello/common/list_item",
             :locals  => { :item => @user, :accessor => "id", :columns => ["login"], :name => controller_display_name }
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @user.login
      render :json => { :no_match => true }
    end
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => error
    notify.exception error
    #transaction, if something goes wrong with the creation of the permission, we will need to delete the user
    @user.destroy unless @user.new_record?
    render :json => @user.errors, :status => :bad_request
  end

  def update
    params[:user].delete :login

    @user.update_attributes!(params[:user])

    notify.success _("User updated successfully.")
    attr = params[:user].first.last if params[:user].first
    attr ||= ""

    if !search_validate(User, user.id, params[:search], :login)
      notify.message _("'%s' no longer matches the current search criteria.") % @user.login
    end

    render :text => attr
  end

  def update_locale
    locale = params[:locale][:locale]
    if Katello.config.available_locales.include? locale
      @user.default_locale = locale
      I18n.locale          = locale if @user.id == current_user.id
    else
      @user.default_locale = nil
    end
    @user.save!
    notify.success _("User updated successfully.")
    redirect_to "#{users_path(:id => @user)}#panel=user_#{@user.id}"
  end

  def update_preference
    preference = params[:preference]
    if preference
      @user.preferences[:user] = { } unless @user.preferences.key? :user
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

    render :partial => "edit_environment",
           :locals  => { :user            => @user,
                         :editable        => can_edit_user?,
                         :name            => controller_display_name,
                         :accessible_envs => accessible_envs }
  end

  def update_environment
    if params['org_id'].present?
      @organization = Organization.find_by_id(params['org_id'].try(:to_i))

      @user.default_environment = @organization.library
      @user.default_org         = @organization.id
      @user.save!

      notify.success _("User organization default updated successfully.")

      render :json => { :org => @organization.name }
    else
      render :json => { :org => _("No organization default set for this user.") }
    end
  end

  def update_roles
    params[:user] = { "role_ids" => [] } unless params.key? :user

    #Add in the own role if updating roles, cause the user shouldn't see his own role
    params[:user][:role_ids] << @user.own_role.id

    if  @user.update_attributes(params[:user])
      notify.success _("User updated successfully.")

      if !search_validate(User, @user.id, params[:search], :login)
        notify.message _("'%s' no longer matches the current search criteria.") % @user.login
      end

      render :nothing => true
      return
    end
    notify.invalid_record @user
    render :text => @user.errors, :status => :ok
  end

  def destroy
    @user.destroy
    if @user.destroyed?
      notify.success _("User '%s' was deleted.") % @user[:login]
      #render and do the removal in one swoop!
      render :partial => "katello/common/list_remove", :locals => { :id => params[:id], :name => controller_display_name }
    else
      err_msg = N_("Removal of the user failed. If you continue having trouble with this, please contact an Administrator.")
      notify.error err_msg
      render :nothing => true
    end
  end

  def clear_helptips
    @user.clear_helptips
    notify.success _("Disabled help tips have been re-enabled.")
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
    Katello.config.warden == 'ldap'
  end

  #method for saving the user's default org
  def setup_default_org
    org = params[:org]
    if org && !org.nil?
      current_user.default_org = org
      default_org = Organization.find_by_id(current_user.default_org)
      current_user.save!
      notify.success _("Default Organization: '%s' saved.") % default_org.name
    else
      current_user.default_org = nil
      current_user.save!
      notify.success _("Default Organization no longer selected.")
    end
    render :text => :ok
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
                       :col           => ['login'],
                       :titles        => [_('Login')],
                       :create        => _('User'),
                       :create_label => _('+ New User'),
                       :name          => controller_display_name,
                       :ajax_load     => true,
                       :ajax_scroll   => items_users_path,
                       :enable_create => false, # TODO: ENGINE disable until nutupane http://projects.theforeman.org/issues/3436
                       :search_class  => User }
  end

  def controller_display_name
    return 'user'
  end

  def default_notify_options
    super.merge :organization => nil
  end

end
end
