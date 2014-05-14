#
# Copyright 2014 Red Hat, Inc.
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
class Api::V1::UsersController < Api::V1::ApiController

  before_filter :find_user, :only => [:show, :update, :destroy, :add_role, :remove_role, :list_roles]
  before_filter :find_user_by_login, :only => [:list_owners]
  before_filter :authorize
  respond_to :json

  def rules
    index_test  = lambda { User.any_readable? }
    create_test = lambda { User.creatable? }

    read_test        = lambda { @user.readable? }
    edit_test        = lambda { @user.editable? }
    delete_test      = lambda { @user.deletable? }
    list_owners_test = lambda { @user.id == User.current.id } #user can see only his/her owners

    { :index           => index_test,
      :show            => read_test,
      :create          => create_test,
      :update          => edit_test,
      :destroy         => delete_test,
      :list_owners     => list_owners_test,
      :add_role        => edit_test,
      :remove_role     => edit_test,
      :list_roles      => edit_test,
      :sync_ldap_roles => create_test # expensive operation, set high perms to avoid DOS
    }
  end

  def param_rules
    { :create => [:login, :password, :mail, :email, :disabled, :default_environment_id, :default_locale],
      :update => { :user => [:password, :mail, :email, :disabled, :default_environment_id, :default_locale] }
    }
  end

  def_param_group :user do
    param :email, String, :required => true, :action_aware => true
    param :password, String, :required => true, :action_aware => true
    param :default_environment_id, Integer, :action_aware => true
    param :disabled, :bool, :action_aware => true
  end

  api :GET, "/users", N_("List users")
  param :email, String, :desc => N_("filter by email")
  param :disabled, :bool, :desc => N_("filter by disabled flag")
  param :login, String, :desc => N_("filter by login")
  def index
    respond :collection => User.readable.where(query_params)
  end

  api :GET, "/users/:id", N_("Show a user")
  def show
    @user[:allowed_organizations] = @user.allowed_organizations
    @user[:roles] = @user.katello_roles
    respond
  end

  api :POST, "/users", N_("Create an user")
  param :login, String, :required => true
  param_group :user
  def create
    # warning - request already contains "login" and "password" (logged user)
    @user = User.create!(:login => params[:login],
                         :password => params[:password],
                         :email    => params[:email],
                         :disabled => params[:disabled]) do |user|
                           user.default_locale = params[:default_locale] if params[:default_locale]
                         end

    if params[:default_organization_id]
      @organization = Organization.where(:label => params[:default_organization_id]).first
      @user.default_environment = @organization.library
      @user.default_org = @organization.id
      @user.save!
    end

    respond
  end

  api :PUT, "/users/:id", N_("Update an user")
  param_group :user
  def update
    user_params = params[:user].reject { |k, _| k == 'default_organization_id' }

    @user.update_attributes!(user_params)

    if params[:user].key?(:default_organization_id)
      if params[:user][:default_organization_id].present?
        @organization = Organization.where(:label => params[:user][:default_organization_id]).first
        @user.default_environment = @organization.library
        @user.default_org = @organization.id
      else
        @user.default_environment = nil
      end
    end

    if !params[:default_locale].blank?
      #TODO: this should be placed in model validations
      if Katello.config.available_locales.include? user_params[:default_locale]
        @user.default_locale = user_params[:default_locale]
      end
    end
    @user.save!
    respond
  end

  api :DELETE, "/users/:id", N_("Destroy an user")
  def destroy
    @user.destroy
    respond :message => _("Deleted user '%s'") % params[:id]
  end

  api :GET, "/users/:user_id/roles", N_("List roles assigned to a user")
  #TODO: create rabl
  def list_roles
    @user.set_ldap_roles if Katello.config.ldap_roles
    respond_for_index :collection => @user.roles.non_self
  end

  api :GET, "/users/sync_ldap_roles", N_("Synchronises roles for all users with LDAP groups")
  def sync_ldap_roles
    User.all.each { |user| user.set_ldap_roles }
    respond_for_status :message => _("Roles for all users were synchronised with LDAP groups")
  end

  api :POST, "/users/:user_id/roles", N_("Assign a role to a user")
  param :role_id, Integer
  def add_role
    role = Role.find(params[:role_id])
    @user.roles << role
    @user.save!
    respond_for_status :message => _("User '%{login}' assigned to role '%{rolename}'") % { :login => @user.login, :rolename => role.name }
  end

  api :DELETE, "/users/:user_id/roles/:id", N_("Remove user's role")
  def remove_role
    role = Role.find(params[:id])
    @user.roles.delete(role)
    @user.save!
    respond_for_status :message => _("User '%{login}' unassigned from role '%{rolename}'") % { :login => @user.login, :rolename => role.name }
  end

  # rhsm
  def list_owners
    orgs = @user.allowed_organizations
    # rhsm expects owner (Candlepin format)
    # rubocop:disable SymbolName
    respond_for_index :collection => orgs.map { |o| { :key => o.label, :displayName => o.name } }
  end

  private

  def find_user
    @user = User.find(params[:user_id] || params[:id])
    fail HttpErrors::NotFound, _("Couldn't find user '%s'") % params[:id] if @user.nil?
    @user
  end

  def find_user_by_login
    @user = User.find_by_login(params[:login])
    fail HttpErrors::NotFound, _("Couldn't find user '%s'") % params[:login] if @user.nil?
    @user
  end

end
end
