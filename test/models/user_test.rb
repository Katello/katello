#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'test/models/user_base'
require 'test/auth_helper'


class UserCreateTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def setup
    super
    @user = build(:user, :batman)
  end

  def teardown
    @user.destroy
  end

  def test_create
    assert @user.save
  end

  def test_create_with_short_password
    @user.password = "a"
    assert !@user.save
    assert @user.errors.has_key?(:password)
  end

  def test_before_create_self_role
    @user.save
    assert !@user.own_role.nil?
  end

  def test_before_save_hash_password
    @user.save
    assert @user.password != "Villa"
  end

end


class UserInstanceTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def setup
    super
    User.current = @admin
  end

  def test_destroy
    @no_perms_user.destroy
    assert @no_perms_user.destroyed?
  end

  def test_before_destroy_remove_self_role
    role = @no_perms_user.own_role
    @no_perms_user.destroy
    assert_raises ActiveRecord::RecordNotFound do 
      Role.find(role.id)
    end
  end

  def test_before_destroy_not_last_superuser
    assert !@admin.destroy
  end
end


class UserClassTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def test_authenticate
    assert User.authenticate!(@no_perms_user.username, @no_perms_user.username)
  end

  def test_authenticate_fails_with_wrong_password
    assert_nil User.authenticate!(@no_perms_user.username, '')
  end

  def test_authenticate_fails_with_non_user
    assert_nil User.authenticate!('fake_user', '')
  end

  def test_authenticate_fails_with_disabled_user
    assert_nil User.authenticate!(@disabled_user.username, @disabled_user.password)
  end

end


class UserLdapTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def self.before_suite
    super
    AppConfig.warden = 'ldap'
    @@user = User.create_ldap_user!('testuser')
  end

  def test_find_created
    assert User.find_by_username('testuser')
  end

  def test_no_email
    assert @@user.email.nil?
  end

  def test_own_role
    assert !@@user.own_role.nil?
  end
end



class UserDefaultEnvTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch']
    models    = ['User', 'KTEnvironment', 'Repository', 'System']
    disable_glue_layers(services, models)
  end

  def setup
    super
    @org = @acme_corporation
    @env = @dev
    @user = @admin
  end

  def test_set_default_env
    @user.default_environment = @dev
    @user.save!
    @user = @user.reload
    assert @user.default_environment == @env
  end

  def test_find_by_default_env
    @user.default_environment = @dev
    @user.save!
    assert User.find_by_default_environment(@env.id).first == @user
  end

  def test_default_env_removed
    @user.default_environment = @dev
    @user.save!
    @env.destroy
    assert User.find_by_default_environment(@env.id).empty?
    assert @user.default_environment.nil?
  end
end


class UserOrganizationAccess < MiniTest::Rails::ActiveSupport::TestCase
  include AuthorizationHelperMethods
  include TestUserBase

  def setup
    super
    @user = @no_perms_user
    @org = @acme_organization
    @org2 = FactoryGirl.create(:organization, :label=>"foolabel", :name=>"fooname")
  end

  def test_access_two_orgs
    assert @user.allowed_organizations.size == 0
    allow(@user.own_role, [:read], :providers, nil, @org)
    allow(@user.own_role,[:read], :providers, nil, @org2)
    @user.save!
    assert @user.allowed_organizations.size == 2
  end

end