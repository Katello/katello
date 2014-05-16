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
    @host_collections = katello_host_collections
    @organization = get_organization
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
    System.any_instance.stubs(:releaseVer).returns(1)
    System.any_instance.stubs(:refresh_subscriptions).returns(true)
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

    models
    permissions
  end

  def test_index
    get :index, :organization_id => get_organization.id

    assert_response :success
    assert_template 'api/v2/systems/index'
  end

  def test_index_protected
    allowed_perms = [@view_permission]
    denied_perms = [@create_permission, @update_permission, @destroy_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.id
    end
  end

  def test_show
    get :show, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/show'
  end

  def test_show_protected
    allowed_perms = [@view_permission]
    denied_perms = [@create_permission, @update_permission, @destroy_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
      get :show, :id => @system.uuid
    end
  end

  def test_refresh_subscriptions
    put :refresh_subscriptions, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/show'
  end

  def test_refresh_subscriptions_protected
    allowed_perms = [@update_permission]
    denied_perms = [@create_permission, @view_permission, @destroy_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
      put :refresh_subscriptions, :id => @system.uuid
    end
  end

  def test_tasks
    items = mock()
    items.stubs(:retrieve).returns([], 0)
    items.stubs(:total_items).returns([])
    Glue::ElasticSearch::Items.stubs(:new).returns(items)
    System.any_instance.expects(:import_candlepin_tasks)

    get :tasks, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/tasks'
  end

  def test_tasks_protected
    allowed_perms = [@view_permission]
    denied_perms = [@create_permission, @update_permission, @destroy_permission]

    assert_protected_action(:tasks, allowed_perms, denied_perms) do
      get :tasks, :id => @system.uuid
    end
  end

  def test_available_host_collections
    get :available_host_collections, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/available_host_collections'
  end

  def test_available_host_collections_protected
    allowed_perms = [@view_permission]
    denied_perms = [@create_permission, @update_permission, @destroy_permission]

    assert_protected_action(:available_host_collections, allowed_perms, denied_perms) do
      get :available_host_collections, :id => @system.uuid
    end
  end

end
end
