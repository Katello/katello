# encoding: utf-8
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

require "katello_test_helper"

module Katello
class Api::V2::SystemPackagesControllerTest < ActionController::TestCase

  include Support::ForemanTasks::Task

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    super
  end

  def permissions
    @view_permission = :view_content_hosts
    @create_permission = :create_content_hosts
    @update_permission = :edit_content_hosts
    @destroy_permission = :destroy_content_hosts
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'

    @system = katello_systems(:simple_server)
    permissions
  end

  def test_install_package
    assert_async_task ::Actions::Katello::System::Package::Install do |system, packages|
      system.id == @system.id && packages == %w(foo)
    end

    put :install, :system_id => @system.uuid, :packages => %w(foo)

    assert_response :success
  end

  def test_install_bad_package
    put :install, :system_id => @system.uuid, :packages => ["foo343434*"]

    assert_response 400
  end

  def test_install_group
    assert_async_task ::Actions::Katello::System::PackageGroup::Install do |system, groups|
      system.id == @system.id && groups == %w(blah)
    end

    put :install, :system_id => @system.uuid, :groups => %w(blah)

    assert_response :success
  end

  def test_upgrade
    assert_async_task ::Actions::Katello::System::Package::Update do |system, packages|
      system.id == @system.id && packages == %w(foo bar)
    end

    put :upgrade, :system_id => @system.uuid, :packages => %w(foo bar)

    assert_response :success
  end

  def test_upgrade_group_fail
    put :upgrade, :system_id => @system.uuid, :groups => %w(foo bar)

    assert_response 400
  end

  def test_upgrade_all
    assert_async_task ::Actions::Katello::System::Package::Update do |system, packages|
      system.id == @system.id && packages == []
    end

    put :upgrade_all, :system_id => @system.uuid

    assert_response :success
  end

  def test_remove
    assert_async_task ::Actions::Katello::System::Package::Remove do |system, packages|
      system.id == @system.id && packages == %w(foo)
    end

    put :remove, :system_id => @system.uuid, :packages => %w(foo)

    assert_response :success
  end

  def test_remove_group
    assert_async_task ::Actions::Katello::System::PackageGroup::Remove do |system, groups|
      system.id == @system.id && groups == %w(blah)
    end

    put :remove, :system_id => @system.uuid, :groups => %w(blah)

    assert_response :success
  end

  def test_permissions
    #all actions have the same perms
    good_perms = [@update_permission]
    bad_perms = [@view_permission, @create_permission, @destroy_permission]

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
end
