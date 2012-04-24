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

class Api::UsersController < Api::ApiController

  before_filter :find_user, :only => [:show, :update, :destroy, :add_role, :remove_role, :list_roles]
  before_filter :find_user_by_username, :only => [:list_owners]
  before_filter :authorize
  respond_to :json

  def rules
    index_test  = lambda { User.any_readable? }
    create_test = lambda { User.creatable? }

    read_test        = lambda { @user.readable? }
    edit_test        = lambda { @user.editable? }
    delete_test      = lambda { @user.deletable? }
    user_helptip     = lambda { true }                        #everyone can enable disable a helptip
    list_owners_test = lambda { @user.id == User.current.id } #user can see only his/her owners

    { :index       => index_test,
      :show        => read_test,
      :create      => create_test,
      :update      => edit_test,
      :destroy     => delete_test,
      :list_owners => list_owners_test,
      :add_role    => edit_test,
      :remove_role => edit_test,
      :list_roles  => edit_test,
      :report      => index_test,
      :sync_ldap_roles => create_test # expensive operation, set high perms to avoid DOS
    }
  end

  def param_rules
    { :create => [:username, :password, :email, :disabled, :default_environment_id],
      :update => { :user => [:password, :email, :disabled, :default_environment_id] }
    }
  end

  def index
    render :json => (User.readable.where query_params).to_json
  end

  def show
    render :json => @user
  end

  def create
    # warning - request already contains "username" and "password" (logged user)
    user = User.create!(:username => params[:username],
                        :password => params[:password],
                        :email    => params[:email],
                        :disabled => params[:disabled])

    user.default_environment = KTEnvironment.find(params[:default_environment_id]) if params[:default_environment_id]
    render :json => user.to_json
  end

  def update
    user_params = params[:user].reject { |k, _| k == 'default_environment_id' }
    @user.update_attributes!(user_params)
    @user.default_environment = if params[:user][:default_environment_id]
                                  KTEnvironment.find(params[:user][:default_environment_id])
                                else
                                  nil
                                end
    render :json => @user.to_json
  end

  def destroy
    @user.destroy
    render :text => _("Deleted user '#{params[:id]}'"), :status => 200
  end

  def list_roles
    @user.set_ldap_roles if AppConfig.ldap_roles
    render :json => @user.roles.non_self.to_json
  end

  def sync_ldap_roles
    User.all.each { |user| user.set_ldap_roles }
    render :text => _("Roles for all users were synchronised with LDAP groups"), :status => 200
  end 

  def add_role
    role = Role.find(params[:role_id])
    @user.roles << role
    @user.save!
    render :text => _("User '#{@user.username}' assigned to role '#{role.name}'"), :status => 200
  end

  def remove_role
    role = Role.find(params[:id])
    @user.roles.delete(role)
    @user.save!
    render :text => _("User '#{@user.username}' unassigned from role '#{role.name}'"), :status => 200

  end

  def report
    users_report = User.report_table(:all,
                                     :only    => [:username, :created_at, :updated_at],
                                     :include => { :roles => { :only => [:name] } })

    respond_to do |format|
      format.html { render :text => users_report.as(:html), :type => :html and return }
      format.text { render :text => users_report.as(:text, :ignore_table_width => true) }
      format.csv { render :text => users_report.as(:csv) }
      format.pdf { send_data(users_report.as(:pdf),
                             :filename => "katello_users_report.pdf", :type => "application/pdf") }
    end
  end

  # rhsm
  def list_owners
    orgs = @user.allowed_organizations
    # rhsm expects owner (Candlepin format)
    render :json => orgs.map { |o| { :key => o.cp_key, :displayName => o.name } }
  end

  private

  def find_user
    @user = User.find(params[:user_id] || params[:id])
    raise HttpErrors::NotFound, _("Couldn't find user '#{params[:id]}'") if @user.nil?
    @user
  end

  def find_user_by_username
    @user = User.find_by_username(params[:username])
    raise HttpErrors::NotFound, _("Couldn't find user '#{params[:username]}'") if @user.nil?
    @user
  end

end
