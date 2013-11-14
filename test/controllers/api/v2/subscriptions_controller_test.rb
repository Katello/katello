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

class Api::V2::SubscriptionsControllerTest < Minitest::Rails::ActionController::TestCase

  fixtures :all

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def models
    @system = systems(:simple_server)
    @products = products
  end

  def permissions
    @read_permission = UserPermission.new(:read_systems, :organizations, nil, @system.organization)
    @create_permission = UserPermission.new(:register_systems, :organizations, nil, @system.organization)
    @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system.organization)
    @no_permission = NO_PERMISSION
  end

  def setup
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    System.any_instance.stubs(:subscribe).returns(true)
    System.any_instance.stubs(:unsubscribe).returns(true)
    System.any_instance.stubs(:unsubscribe_all).returns(true)
    System.any_instance.stubs(:filtered_pools).returns([])
    System.any_instance.stubs(:releaseVer).returns(1)
    System.any_instance.stubs(:consumed_entitlements).returns([])
    @fake_search_service = @controller.load_search_service(FakeSearchService.new)

    models
    permissions
  end

  def test_index
    get :index, :system_id => @system.uuid

    assert_response :success
    assert_template 'api/v2/subscriptions/index'
  end

  def test_available
    System.any_instance.expects(:filtered_pools)
    get :available, :system_id => @system.uuid

    assert_response :success
    assert_template 'api/v2/subscriptions/index'
  end

  def test_create
    System.any_instance.expects(:subscribe)
    post :create, :system_id => @system.uuid, :quantity => 1, :pool => 'redhat'

    assert_response :success
    assert_template 'api/v2/subscriptions/create'
  end

  def test_destroy
    System.any_instance.expects(:unsubscribe)
    post :destroy, :system_id => @system.uuid, :id => 1

    assert_response :success
    assert_template 'api/v2/subscriptions/show'
  end

  def test_destroy_all
    System.any_instance.expects(:unsubscribe_all)
    post :destroy_all, :system_id => @system.uuid, :id => 1

    assert_response :success
    assert_template 'api/v2/subscriptions/show'
  end

end
