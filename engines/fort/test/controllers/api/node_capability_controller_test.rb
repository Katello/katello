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

require "test_helper"

require 'support/fake_node_capability'

class Api::V1::NodeCapabilitiesControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)
    login_user(User.find(users(:admin)), @org)

    @system = System.find(systems(:simple_server))
    @node = Node.create(:system => @system)

    @read_perm = UserPermission.new(:read, :organizations, nil, nil)
    @edit_perm = UserPermission.new(:manage_nodes, :organizations, nil, nil)
  end

  test 'test index should be successful' do
    get :index, :node_id => @node.id
    assert_response :success
    assert_protected_action(:index, [@read_perm, @edit_perm], [NO_PERMISSION]) do
      get :index, :node_id => @node.id
    end
  end

  test "test_show_should_be_successful" do
    FakeNodeCapability.create!(:node => @node)

    get :show, :node_id => @node.id, :id => FakeNodeCapability::TYPE
    assert_response :success

    assert_protected_action(:show, [@read_perm, @edit_perm], [NO_PERMISSION]) do
      get :show, :node_id => @node.id, :id => FakeNodeCapability::TYPE
    end
  end

  test "test create should be successful" do
    post :create, :node_id => @node.id, :capability => {:type => FakeNodeCapability::TYPE}
    assert_response :success

    assert_protected_action(:create, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      post :create, :node_id => @node.id, :capability => {:type => FakeNodeCapability::TYPE}
    end

  end

  test "test destroy should be successful" do
    FakeNodeCapability.create!(:node => @node)

    delete :destroy, :node_id => @node.id, :id => FakeNodeCapability::TYPE
    assert_response :success
    assert_empty Node.find(@node.id).capabilities
  end

  test "test_destroy permission" do
    FakeNodeCapability.create!(:node => @node)

    assert_protected_action(:destroy, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      delete :destroy, :node_id => @node.id, :id => FakeNodeCapability::TYPE
    end
  end

  test "test update should be successful" do
    FakeNodeCapability.create!(:node => @node)

    post :update, :node_id => @node.id, :id => FakeNodeCapability::TYPE, :capability => {:configuration => {:foo => 'bar'}}
    assert_response :success

    assert_protected_action(:update, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      post :update, :node_id => @node.id, :id => FakeNodeCapability::TYPE, :capability => {:configuration => {:foo => 'bar'}}
    end

  end

end
