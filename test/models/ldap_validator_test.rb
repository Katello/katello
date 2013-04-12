# encoding: utf-8
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

require 'minitest_helper'


class LdapValidatorTest < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    # TODO: RAILS32 remove top reference to load_fixtures
    if @loaded_fixtures.nil?
      @loaded_fixtures = load_fixtures
    end
    configure_runcible

    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['User', 'Organization', 'LdapGroupRole']
    disable_glue_layers(services, models)
  end

  def setup
    Katello.config[:warden] = 'ldap'
    Katello.config[:validate_ldap] = 'true'
    Katello.config[:katello?] = 'false'
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)
    @dev                = KTEnvironment.find(environments(:dev).id)
    @user = build(:user, :batman)
  end

  def build_role
    @role = Role.new
    @role.name = "Role"
    @role.description = "Description"
    @role.save
  end

  def test_valid_login
    LdapFluff.any_instance.stubs(:valid_user?).returns(true)
    assert @user.save
  end

  def test_invalid_login
    LdapFluff.any_instance.stubs(:valid_user?).returns(false)
    assert !@user.save
    assert_includes @user.errors, :username
  end

  def test_hidden_batman
    LdapFluff.any_instance.stubs(:valid_user?).returns(false)
    @user.username = "hidden-batman"
    assert @user.save
  end

  def test_ldap_validation_disabled
    Katello.config[:validate_ldap] = false
    LdapFluff.any_instance.stubs(:valid_user?).returns(false)
    assert @user.save
  end

  def test_ldap_disabled
    Katello.config[:warden] = 'database'
    LdapFluff.any_instance.stubs(:valid_user?).returns(false)
    assert @user.save
  end

  def test_ldap_group
    build_role
    LdapFluff.any_instance.stubs(:valid_group?).returns(true)
    lgr = LdapGroupRole.new
    lgr.role = @role
    lgr.ldap_group = "superheros"
    assert lgr.save
  end

  def test_ldap_group_invalid
    build_role
    LdapFluff.any_instance.stubs(:valid_group?).returns(false)
    lgr = LdapGroupRole.new
    lgr.role = @role
    lgr.ldap_group = "superheros"
    assert !lgr.save
    assert_includes lgr.errors, :ldap_group
  end
end

