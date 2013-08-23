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

class Api::V1::NodesControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)
    @library = @org.library
    login_user(User.find(users(:admin)), @org)
    @system = System.find(systems(:simple_server))

    @read_perm = UserPermission.new(:read, :organizations, nil, nil)
    @edit_perm = UserPermission.new(:manage_nodes, :organizations, nil, nil)

  end

  test 'test index should be successful' do
    get :index
    assert_response :success

    assert_protected_action(:index, [@read_perm, @edit_perm], [NO_PERMISSION]) do
      get :index
    end
  end

  test "test_show_should_be_successful" do
    node = Node.create(:system=>@system)

    get :show, :id=>node.id
    assert_response :success

    assert_protected_action(:show, [@read_perm, @edit_perm], [NO_PERMISSION]) do
      get :show, :id=>node.id
    end
  end

  test "test create should be successful" do
    post :create, :node=>{:system_id=>@system.id}
    assert_response :success

    assert_protected_action(:create, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      post :create, :node=>{:system_id=>@system.id}
    end
  end

  test "test destroy should be successful" do
    node = Node.create(:system=>@system)

    delete :destroy, :id=>node.id
    assert_response :success
    assert_empty Node.where(:id=>node.id)
  end

  test "test_destroy permission" do
    node = Node.create(:system=>@system)
    assert_protected_action(:destroy, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      delete :destroy, :id=>node.id
    end
  end

  test "test system should be successful" do
    node = Node.create(:system=>@system)

    post :sync, :id=>node.id
    assert_response :success

    assert_protected_action(:sync, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      post :sync, :id=>node.id
    end
  end

  test "test update should be successful" do
    node = Node.create(:system=>@system)

    put :update, {:id=>node.id, :node=>{:environment_ids=>[@library.id]}}
    assert_response :success
    assert_includes Node.find(node.id).environments, @library

    assert_protected_action(:update, [@edit_perm], [@read_perm, NO_PERMISSION]) do
      put :update, {:id=>node.id}
    end
  end

end
