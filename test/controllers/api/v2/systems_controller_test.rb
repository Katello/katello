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
class Api::V2::SystemsControllerTest < ActionController::TestCase

  def self.before_suite
    models = ["System", "KTEnvironment",  "ContentViewEnvironment", "ContentView"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    super
  end

  def models
    @system = katello_systems(:simple_server)
    @system_groups = katello_system_groups
  end

  def permissions
    @read_permission = UserPermission.new(:read_systems, :organizations, nil, @system.organization)
    @create_permission = UserPermission.new(:register_systems, :organizations, nil, @system.organization)
    @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system.organization)
    @edit_permission = UserPermission.new(:edit_systems, :organizations, nil, @system.organization)
    @no_permission = NO_PERMISSION
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    System.any_instance.stubs(:releaseVer).returns(1)
    System.any_instance.stubs(:refresh_subscriptions).returns(true)
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

    models
    permissions
  end

  def test_index
    get :index, :organization_id => get_organization.label

    assert_response :success
    assert_template 'api/v2/systems/index'
  end

  def test_show
    get :show, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/show'
  end

  def test_refresh_subscriptions
    put :refresh_subscriptions, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/show'
  end

  def test_tasks
    skip "Getting failure in Jenkins. See github issue #3381"
    items = mock()
    items.stubs(:retrieve).returns([], 0)
    items.stubs(:total_items).returns([])
    Glue::ElasticSearch::Items.stubs(:new).returns(items)
    System.any_instance.expects(:import_candlepin_tasks)

    get :tasks, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/tasks'
  end

  def test_available_system_groups
    get :available_system_groups, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/available_system_groups'
  end

  def test_add_system_groups
    expected_ids = @system_groups.collect {|group| group.id}
    post :add_system_groups, :id => @system.uuid, :system_group_ids => expected_ids

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, expected_ids
  end

  def test_add_system_groups_empty
    expected_ids = []
    post :add_system_groups, :id => @system.uuid, :system_group_ids => expected_ids

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, expected_ids
  end

  def test_add_system_groups_nil
    post :add_system_groups, :id => @system.uuid, :system_group_ids => nil

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, []
  end

end
end
