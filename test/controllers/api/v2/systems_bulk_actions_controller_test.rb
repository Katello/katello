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

require "katello_test_helper"

module Katello
class Api::V2::SystemsBulkActionsControllerTest < ActionController::TestCase

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def permissions
    @read_permission = UserPermission.new(:read_systems, :organizations, nil, @system1.organization)
    @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system1.organization)
    @delete_permission = UserPermission.new(:delete_systems, :organizations, nil, @system1.organization)
    @update_group_perm = UserPermission.new(:update, :system_groups, [@system_group1.id, @system_group2.id], @system1.organization)
    @no_permission = NO_PERMISSION
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'

    @system1 = katello_systems(:simple_server)
    @system2 = katello_systems(:simple_server2)
    @system_ids = [@system1.id, @system2.id]
    @systems = [@system1, @system2]
    @system_ids = @systems.map(&:id)

    @org = @system1.organization
    @system_group1 = katello_system_groups(:simple_group)
    @system_group2 = katello_system_groups(:another_simple_group)

    permissions

    System.any_instance.stubs(:update_system_groups)
    System.stubs(:find).returns(@systems)
  end

  def test_add_system_group
    assert_equal 1, @system1.system_groups.count # system initially has simple_group
    put :bulk_add_system_groups, {:included => {:ids => @system_ids},
                                  :organization_id => @org.label,
                                  :system_group_ids => [@system_group1.id, @system_group2.id]}

    assert_response :success
    assert_equal 2, @system1.system_groups.count
  end

  def test_remove_system_group
    assert_equal 1, @system1.system_groups.count # system initially has simple_group
    put :bulk_remove_system_groups, {:included => {:ids => @system_ids},
                                      :organization_id => @org.label,
                                      :system_group_ids => [@system_group1.id, @system_group2.id]}

    assert_response :success
    assert_equal 0, @system1.system_groups.count
  end

  def test_install_package
    @system1.expects(:install_packages).with(["foo"]).returns(TaskStatus.new)
    @system2.expects(:install_packages).with(["foo"]).returns(TaskStatus.new)

    put :install_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package', :content => ['foo']

    assert_response :success
  end

  def test_update_package
    @system1.expects(:update_packages).with(["foo"]).returns(TaskStatus.new)
    @system2.expects(:update_packages).with(["foo"]).returns(TaskStatus.new)

    put :update_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package', :content => ['foo']

    assert_response :success
  end

  def test_remove_package
    @system1.expects(:uninstall_packages).with(["foo"]).returns(TaskStatus.new)
    @system2.expects(:uninstall_packages).with(["foo"]).returns(TaskStatus.new)

    put :remove_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package', :content => ['foo']

    assert_response :success
  end

  def test_install_package_group
    @system1.expects(:install_package_groups).with(["foo group"]).returns(TaskStatus.new)
    @system2.expects(:install_package_groups).with(["foo group"]).returns(TaskStatus.new)

    put :install_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package_group', :content => ['foo group']

    assert_response :success
  end

  def test_update_package_group
    @system1.expects(:install_package_groups).with(["foo group"]).returns(TaskStatus.new)
    @system2.expects(:install_package_groups).with(["foo group"]).returns(TaskStatus.new)

    put :update_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package_group', :content => ['foo group']

    assert_response :success
  end

  def test_remove_package_group
    @system1.expects(:uninstall_package_groups).with(["foo group"]).returns(TaskStatus.new)
    @system2.expects(:uninstall_package_groups).with(["foo group"]).returns(TaskStatus.new)

    put :remove_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'package_group', :content => ['foo group']

    assert_response :success
  end

  def test_install_errata
    @system1.expects(:install_errata).with(["RHSA-2013:0123"]).returns(TaskStatus.new)
    @system2.expects(:install_errata).with(["RHSA-2013:0123"]).returns(TaskStatus.new)

    put :install_content, :ids => @system_ids, :organization_id => @org.label,
        :content_type => 'errata', :content => ['RHSA-2013:0123']

    assert_response :success
  end

  def test_destroy_systems
    put :destroy_systems, :ids => @system_ids

    assert_response :success
    assert_nil System.find_by_id(@system1.id)
    assert_nil System.find_by_id(@system2.id)
  end

  def test_permissions
    good_perms = [@update_permission]
    good_group_perm = [@update_group_perm]
    bad_perms = [@read_permission, @delete_permission, @no_permission]

    assert_protected_action(:bulk_add_system_groups, good_group_perm, bad_perms) do
      put :bulk_add_system_groups,  {:included => {:ids => @system_ids},
                                        :organization_id => @org.label,
                                        :system_group_ids => [@system_group1.id, @system_group2.id]}
    end

    assert_protected_action(:bulk_remove_system_groups, good_group_perm, bad_perms) do
      put :bulk_remove_system_groups,  {:included => {:ids => @system_ids},
                                        :organization_id => @org.label,
                                        :system_group_ids => [@system_group1.id, @system_group2.id]}
    end

    assert_protected_action(:install_content, good_perms, bad_perms) do
      put :install_content, :ids => @system_ids, :content_type => 'package', :content => ['foo']
    end

    assert_protected_action(:update_content, good_perms, bad_perms) do
      put :update_content, :ids => @system_ids, :content_type => 'package', :content => ['foo']
    end

    assert_protected_action(:remove_content, good_perms, bad_perms) do
      put :remove_content, :ids => @system_ids, :content_type => 'package', :content => ['foo']
    end

    good_perms = [@delete_permission]
    bad_perms = [@read_permission, @update_permission, @no_permission]

    assert_protected_action(:destroy_systems, good_perms, bad_perms) do
      put :destroy_systems, :ids => @system_ids
    end
  end

end
end
