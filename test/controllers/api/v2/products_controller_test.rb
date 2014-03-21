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
class Api::V2::ProductsControllerTest < ActionController::TestCase

  def self.before_suite
    models = ["Product"]
    disable_glue_layers(%w(Candlepin Pulp ElasticSearch), models)
    super
  end

  def models
    @organization = get_organization
    @provider = katello_providers(:fedora_hosted)
    @product = katello_products(:empty_product)
  end

  def permissions
    @read_permission = UserPermission.new(:read, :providers)
    @create_permission = UserPermission.new(:create, :providers)
    @update_permission = UserPermission.new(:update, :providers)
    @no_permission = NO_PERMISSION
  end

  def setup
    setup_controller_defaults_api
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
    permissions
  end

  def test_index
    get :index, :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/products/index'
  end

  def test_index_fail_without_organization_id
    get :index

    assert_response :not_found
  end

  def test_index_protected
    allowed_perms = [@read_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.label
    end
  end

  def test_create
    product_params = {
      :name => 'fedora product',
      :provider_id => @provider.id,
      :description => 'this is my cool new product.'
    }
    post :create, :product => product_params

    assert_response :success
    assert_template %w(katello/api/v2/common/create katello/api/v2/layouts/resource)
  end

  def test_create_fail_without_product
    post :create, :organization_id => @organization.label
    assert_response :bad_request
  end

  def test_create_fail_with_only_provider_id
    # without provider_id it's 500 and this test is for 422 errors
    post :create, :provider_id => @provider.id

    assert_response :bad_request
  end

  def test_create_protected
    allowed_perms = [@create_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:create, allowed_perms, denied_perms) do
      post :create, :product => {:provider_id => @provider.id}, :organization_id => @organization.label
    end
  end

  def test_show
    get :show, :id => @product.id

    assert_response :success
    assert_template 'api/v2/products/show'
  end

  def test_show_protected
    allowed_perms = [@read_permission, @update_permission, @create_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
      get :show, :id => @product.id
    end
  end

  def test_update
    put :update, :id => @product.id, :product => {:name => 'New Name'}

    assert_response :success
    assert_template %w(katello/api/v2/common/update katello/api/v2/layouts/resource)
    assert_equal assigns[:product].name, 'New Name'
  end

  def test_update_product_requires_name
    put :update, :id => @product.id, :product => {:name => nil}

    assert_response :unprocessable_entity
    assert_template %w(katello/api/v2/common/update katello/api/v2/layouts/resource)
    assert_equal assigns[:product].name, nil
  end

  def test_update_sync_plan
    sync_plan = katello_sync_plans(:sync_plan_hourly)
    put :update, :id => @product.id, :product => {:sync_plan_id => sync_plan.id}

    assert_response :success
    assert_template %w(katello/api/v2/common/update katello/api/v2/layouts/resource)
    assert_equal assigns[:product].sync_plan_id, sync_plan.id
  end

  def test_remove_sync_plan
    put :update, :id => @product.id, :product => {:sync_plan_id => nil, :provider_id => @provider.id}

    assert_response :success
    assert_template %w(katello/api/v1/common/update katello/api/v2/layouts/resource)
    assert_equal assigns[:product].sync_plan_id, nil
  end

  def test_update_protected
    allowed_perms = [@update_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:update, allowed_perms, denied_perms) do
      put :update, :id => @product.id, :name => 'New Name'
    end
  end

  def test_destroy
    delete :destroy, :id => @product.id

    assert_response :success
  end

  def test_destroy_protected
    allowed_perms = [@update_permission, @create_permission]
    denied_perms = [@no_permission, @read_permission]

    assert_protected_action(:destroy, allowed_perms, denied_perms) do
      delete :destroy, :id => @product.id
    end
  end

end
end
