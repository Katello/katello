# encoding: utf-8
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

require './test/models/user_base'


class UserClassTest < UserTestBase

  def test_authenticate
    refute_nil User.authenticate!(@no_perms_user.username, @no_perms_user.username)
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

  def test_cp_oauth_header
    User.current = @admin
    assert        User.cp_oauth_header.key?('cp-user')
    assert_equal  @admin.username, User.cp_oauth_header['cp-user']
  end

  def test_consumer?
    refute User.consumer?
  end

  def test_with_default_environment
    @admin.default_environment = @dev
    @admin.save!
    user_list = User.with_default_environment(@dev.id)

    assert_includes user_list, @admin
  end

end


class UserCreateTest < UserTestBase

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
    assert_includes @user.errors, :password
  end

  def test_create_with_bad_username
    @user.username = 'bad_<blink>hacker</blink>'
    assert !@user.save
    assert_includes @user.errors, :username
  end

  def test_before_create_self_role
    @user.save

    refute_nil @user.own_role
  end

  def test_before_save_hash_password
    @user.save

    refute_equal "Villa", @user.password
  end

  def test_i18n_username
    uname = "ಬoo0000"
    @user.username = uname
    assert        @user.save
    refute_nil    @user.remote_id
    assert_empty  @user.errors
    refute_nil    User.find_by_username(uname)
  end

  def test_email_username
    email = "foo@redhat.com"
    @user.username = email
    assert        @user.save
    assert_empty  @user.errors
    refute_nil    User.find_by_username(email)
  end

end


class UserTest < UserTestBase

  def setup
    super
    User.current = @admin
    @admin_role  = Role.find(roles(:administrator))
  end

  def test_own_role
    refute_nil @admin.own_role
  end

  def test_destroy
    @no_perms_user.destroy

    assert @no_perms_user.destroyed?
  end

  def test_destroy_own_role
    role = @no_perms_user.own_role
    @no_perms_user.destroy

    assert_raises ActiveRecord::RecordNotFound do
      Role.find(role.id)
    end
  end

  def test_is_last_super_user?
    assert !@admin.destroy
  end

  def test_defined_roles
    assert_equal [@admin_role], @admin.defined_roles
  end

  def test_defined_role_ids
    assert_equal [@admin_role.id], @admin.defined_role_ids
  end

  def test_has_superadmin_role?
    assert @admin.has_superadmin_role?
  end

  def test_pop_notices
    assert_equal 1, @admin.pop_notices.length
  end

  def test_disable_helptip
    assert @admin.disable_helptip("repositories-index")
  end

  def test_enable_helptip
    assert @admin.enable_helptip("promotions-show")
  end

  def test_clear_helptips
    assert @admin.clear_helptips
  end

  def test_helptip_enabled?
    @admin.clear_helptips
    assert @admin.helptip_enabled?('promotions-show')
  end

  def test_cp_oauth_header
    assert        @admin.cp_oauth_header.key?('cp-user')
    assert_equal  @admin.username, @admin.cp_oauth_header['cp-user']
  end

  def test_send_password_reset
    UserMailer.stub(:send_password_reset, true) do
      assert @admin.send_password_reset
    end
  end

  def test_has_default_environment?
    @admin.default_environment = @dev

    assert @admin.has_default_environment?
  end

  # TODO: should be moved into permission test
  def test_create_or_update_default_system_registration_permission
    permission = @admin.own_role.create_or_update_default_system_registration_permission(@acme_corporation, @dev)

    assert_instance_of Permission, permission
    assert_equal       "environments", permission.resource_type.name
    assert_equal       "default systems reg permission", permission.name
  end

  def test_default_environment
    @admin.default_environment = @dev

    assert_equal @dev, @admin.default_environment
  end

  def test_default_environment=
    assert @admin.default_environment = @dev
  end

  def test_default_locale
    @admin.default_locale = "en"
    assert_equal "en", @admin.default_locale
  end

  def test_default_locale=
    assert @admin.default_locale = "en"
  end

  def test_default_org
    @admin.default_org = @acme_corporation.id
    assert_equal @acme_corporation, @admin.default_org
  end

  def test_default_org=
    assert @admin.default_org = @acme_corporation.id
  end

  def test_subscriptions_match_system_preference=
    assert @admin.subscriptions_match_system_preference = 'flag-1'
  end

  def test_subscriptions_match_system_preference
    @admin.subscriptions_match_system_preference = 'flag-1'

    assert_equal  'flag-1', @admin.subscriptions_match_system_preference
  end

  def test_subscriptions_match_installed_preference
    assert @admin.subscriptions_match_installed_preference = 'flag-1'
  end

  def test_subscriptions_match_installed_preference=
    @admin.subscriptions_match_installed_preference = 'flag-1'

    assert_equal  'flag-1', @admin.subscriptions_match_installed_preference
  end

  def test_subscriptions_no_overlap_preference
    assert @admin.subscriptions_match_installed_preference = 'flag-1'
  end

  def test_subscriptions_no_overlap_preference=
    @admin.subscriptions_no_overlap_preference = 'flag-1'

    assert_equal  'flag-1', @admin.subscriptions_no_overlap_preference
  end

end


class UserProtectedMethodTest < UserTestBase

  def setup
    super
    User.current = @admin
    @admin_role  = Role.find(roles(:administrator))
  end

  def test_can_be_deleted?
    refute @admin.send(:can_be_deleted?)
  end

  def test_own_role_included_in_roles_without_own_role
    @admin.roles.delete(@admin.own_role)
    refute @admin.valid?
  end
end


class UserInstancePrivateMethodTest < UserTestBase

  def setup
    super
    User.current = @admin
    @admin_role  = Role.find(roles(:administrator))
  end

  def test_generate_token
    @admin.send(:generate_token, :password_reset_token)
    @admin.save!
    @no_perms_user.send(:generate_token, :password_reset_token)

    refute_equal @no_perms_user.password_reset_token, @admin.password_reset_token
  end

  def test_super_admin_check
    assert_raises(ActiveRecord::RecordInvalid) do
      @admin.send(:super_admin_check, @admin_role)
    end
  end

  def test_setup_remote_id
    assert @admin.send(:setup_remote_id)
  end

  def test_generate_remote_id
    refute_equal @admin.send(:generate_remote_id), @admin.username
  end

end


class UserLdapTest < UserTestBase

  def self.before_suite
    super
    options = { :warden => "ldap", :validate_ldap => false }
    config = Katello::Configuration::Node.new(Katello.config.to_hash.update options)
    Katello.stubs(:config).returns(config)
    @@user = User.create_ldap_user!('testuser')
  end

  def setup
    super
    @ldap = Minitest::Mock.new
    @ldap.expect(:authenticate?, true, [@@user.username, @@user.password])
    @ldap.expect(:group_list, ['test_role'], [@@user.username])
    @ldap.expect(:is_in_groups?, true, [@@user.username, []])
  end

  def test_no_email
    assert_nil @@user.email
  end

  def test_find_created
    refute_nil User.find_by_username('testuser')
  end

  def test_authenticate_using_ldap!
    LdapFluff.stub(:new, @ldap) do
      assert_instance_of User, User.authenticate_using_ldap!(@@user.username, @@user.password)
    end
  end

  def test_create_ldap_user!
    options = { :warden => "ldap" }
    override_config(options)
    assert_instance_of User, User.create_ldap_user!('alice')
  end

  def test_clear_existing_ldap_roles
    LdapFluff.stub(:new, @ldap) do
      @@user.set_ldap_roles
      refute_empty @@user.roles

      @@user.clear_existing_ldap_roles
      assert_empty @@user.ldap_roles
    end
  end

  def test_set_ldap_roles
    LdapFluff.stub(:new, @ldap) do
      @@user.set_ldap_roles

      refute_empty @@user.roles
    end
  end

  def test_verify_ldap_roles
    LdapFluff.stub(:new, @ldap) do
      @@user.set_ldap_roles

      assert @@user.verify_ldap_roles
    end
  end

  def test_not_ldap_mode?
    assert @admin.not_ldap_mode?
  end

end


class UserDefaultEnvTest < UserTestBase

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
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
    @user.update_attributes!(:default_environment => @env)
    @user = @user.reload

    assert_equal @env, @user.default_environment
  end

  def test_default_env_removed
    @user.update_attributes!(:default_environment => @env)
    @env.destroy
    @user = @user.reload

    assert_empty  User.with_default_environment(@env.id)
    assert_nil    @user.default_environment
  end

end
