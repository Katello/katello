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

class Api::V2::ProductsControllerTest < Minitest::Rails::ActionController::TestCase

  fixtures :all

  def self.before_suite
    models = ["Product"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def models
    @organization = organizations(:acme_corporation)
    @provider = providers(:fedora_hosted)
    @product = products(:empty_product)
  end

  def permissions
    @read_permission = UserPermission.new(:read, :providers)
    @create_permission = UserPermission.new(:create, :providers)
    @update_permission = UserPermission.new(:update, :providers)
    @no_permission = NO_PERMISSION
  end

  def setup
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @fake_search_service = @controller.load_search_service(FakeSearchService.new)
    models
    permissions
  end

  def test_index
    get :index, :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/products/index'
  end

  def test_index_protected
    allowed_perms = [@read_permission, @update_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.label
    end
  end

  def test_create
    post :create, :name => 'Fedora Product',
                  :provider_id => @provider.id,
                  :description => 'This is my cool new product.'

    assert_response :success
    assert_template 'api/v2/products/show'
  end

  def test_create_fail
    post :create, :description => 'This is my cool new product.'

    assert_response :unprocessable_entity
  end

  def test_create_protected
    allowed_perms = [@create_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:create, allowed_perms, denied_perms) do
      post :create, :provider_id => @provider.id
    end
  end

  def test_show
    get :show, :id => @product.cp_id

    assert_response :success
    assert_template 'api/v2/products/show'
  end

  def test_show_protected
    allowed_perms = [@read_permission, @update_permission, @create_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
      get :show, :id => @product.cp_id
    end
  end

  def test_update
    get :update, :id => @product.cp_id, :name => 'New Name'

    assert_response :success
    assert_template 'api/v2/products/show'
    assert_equal assigns[:product].name, 'New Name'
  end

  def test_update_protected
    allowed_perms = [@update_permission, @create_permission]
    denied_perms = [@no_permission, @read_permission]

    assert_protected_action(:destroy, allowed_perms, denied_perms) do
      get :destroy, :id => @product.cp_id, :name => 'New Name'
    end
  end

  def test_destroy
    get :destroy, :id => @product.cp_id

    assert_response :success
  end

  def test_destroy_protected
    allowed_perms = [@update_permission, @create_permission]
    denied_perms = [@no_permission, @read_permission]

    assert_protected_action(:destroy, allowed_perms, denied_perms) do
      get :destroy, :id => @product.cp_id
    end
  end

end
