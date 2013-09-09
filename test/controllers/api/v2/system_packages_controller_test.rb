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

require "minitest_helper"

class Api::V2::SystemPackagesControllerTest < Minitest::Rails::ActionController::TestCase

  fixtures :all

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def permissions
    @read_permission = UserPermission.new(:read_systems, :organizations, nil, @system.organization)
    @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system.organization)
    @no_permission = NO_PERMISSION
  end

  def setup
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'

    @system = systems(:simple_server)
    permissions
  end

  def test_install_package
    System.any_instance.expects(:install_packages).with(["foo"]).returns(TaskStatus.new)
    put :install, :system_id => @system.uuid, :packages => ["foo"]

    assert_response :success
  end

  def test_install_bad_package
    put :install, :system_id => @system.uuid, :packages => ["foo343434*"]

    assert_response 400
  end

  def test_install_group
    System.any_instance.expects(:install_package_groups).with(["blah"]).returns(TaskStatus.new)
    put :install, :system_id => @system.uuid, :groups => ["blah"]

    assert_response :success
  end

  def test_upgrade
    System.any_instance.expects(:update_packages).with(["foo", "bar"]).returns(TaskStatus.new)
    put :upgrade, :system_id => @system.uuid, :packages => ["foo", "bar"]

    assert_response :success
  end

  def test_upgrade_group_fail
    put :upgrade, :system_id => @system.uuid, :groups => ["foo", "bar"]

    assert_response 400
  end

  def test_upgrade_all
    System.any_instance.expects(:update_packages).with([]).returns(TaskStatus.new)
    put :upgrade_all, :system_id => @system.uuid, :packages => ["foo", "bar"]

    assert_response :success
  end

  def test_upgrade_all_group_fail
    put :upgrade_all, :system_id => @system.uuid, :groups => ["foo", "bar"]

    assert_response 400
  end

  def test_remove
    System.any_instance.expects(:uninstall_packages).with(["foo"]).returns(TaskStatus.new)
    put :remove, :system_id => @system.uuid, :packages => ["foo"]

    assert_response :success
  end

  def test_remove_group
    System.any_instance.expects(:uninstall_package_groups).with(["blah"]).returns(TaskStatus.new)
    put :remove, :system_id => @system.uuid, :groups => ["blah"]

    assert_response :success
  end

  def test_permissions
    #all actions have the same perms
    good_perms = [@update_permission]
    bad_perms = [@read_permission, @no_permission ]

    assert_protected_action(:install, good_perms, bad_perms) do
      put :install, :system_id => @system.uuid, :packages => ["foo*"]
    end

    assert_protected_action(:upgrade, good_perms, bad_perms) do
      put :upgrade, :system_id => @system.uuid, :packages => ["foo*"]
    end

    assert_protected_action(:upgrade_all, good_perms, bad_perms) do
      put :upgrade_all, :system_id => @system.uuid, :packages => ["foo*"]
    end

    assert_protected_action(:remove, good_perms, bad_perms) do
      put :remove, :system_id => @system.uuid, :packages => ["foo*"]
    end
  end

end
