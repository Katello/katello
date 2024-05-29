# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ProductsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @provider = Provider.find(katello_providers(:anonymous).id)
      @product = Product.find(katello_products(:fedora).id)
      @product.stubs(:redhat?).returns(false)
      Product.any_instance.stubs('sync_state_aggregated').returns(:stopped)
    end

    def permissions
      @resource_type = "Katello::Product"
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @delete_permission = :destroy_products
      @sync_permission = :sync_products
      @sync_plan_permission = :view_sync_plans
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/products/index'
    end

    def test_index_name
      get :index, params: { :organization_id => @organization.id, :name => @product.name }

      assert_response :success
      assert_template 'api/v2/products/index'
    end

    def test_index_available_for
      sync_plan = SyncPlan.first
      @product.update_attribute(:sync_plan_id, sync_plan.id)
      get :index, params: { :organization_id => @organization.id, :available_for => 'sync_plan', :sync_plan_id => sync_plan.id }

      ids = JSON.parse(response.body)['results'].map { |prod| prod['id'] }

      assert_response :success
      assert_template 'api/v2/products/index'

      refute_includes ids, @product.id
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_index_custom_products_only
      get :index, params: { organization_id: @organization.id, custom: true }
      body = JSON.parse(response.body)

      assert_equal Katello::Product.custom.count, body['total']
    end

    def test_index_no_custom_products
      get :index, params: { organization_id: @organization.id, redhat_only: true }
      body = JSON.parse(response.body)

      assert_equal 2, body['total']
    end

    def test_create
      product_params = {
        :name => 'fedora product',
        :description => 'this is my cool new product.',
        :label => 'product_label',
      }
      Api::V2::ProductsController.any_instance.expects(:sync_task).with do |action_class, prod, org|
        assert_equal action_class, ::Actions::Katello::Product::Create
        assert_instance_of Product, prod
        assert_equal org, @organization
        prod.organization = @organization
        prod.provider = @provider
        assert_equal product_params[:name], prod.name
        assert_equal product_params[:description], prod.description
        assert_equal product_params[:label], prod.label
      end

      post :create, params: { :product => product_params, :organization_id => @organization.id }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_fail_without_product
      Organization.stubs(:current).returns(@organization)
      post :create

      assert_response :bad_request
    end

    def test_create_protected
      anonymous_provider = Katello::Provider.find(katello_providers(:anonymous).id)
      Organization.any_instance.stubs(:anonymous_provider).returns(anonymous_provider)

      allowed_perms = [@create_permission]
      denied_perms = [@read_permission, @update_permission, @delete_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, params: { :product => {:name => "foo"}, :organization_id => @organization.id }
      end
    end

    def test_create_with_bad_org
      product_params = {
        :name => 'fedora product',
        :description => 'this is my cool new product.',
      }
      post :create, params: { :product => product_params, :organization_id => 'asdfdsafds' }

      assert_response 404
    end

    def test_show
      get :show, params: { :id => @product.id }

      assert_response :success
      assert_template 'api/v2/products/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@update_permission, @create_permission, @delete_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @product.id }
      end
    end

    def test_update
      params = { :name => 'New Name', :description => 'Product Description', :label => 'product_label' }
      assert_sync_task(::Actions::Katello::Product::Update) do |product, product_params|
        assert_equal @product.id, product.id
        assert_equal product_params.key?(:name), true
        assert_equal product_params[:name], params[:name]
        assert_equal product_params.key?(:description), true
        assert_equal product_params[:description], params[:description]
        assert_equal product_params.key?(:label), true
        assert_equal product_params[:label], params[:label]
      end
      put :update, params: { :id => @product.id, :product => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_sync_plan
      sync_plan = katello_sync_plans(:sync_plan_hourly)
      params = {:sync_plan_id => sync_plan.id}
      assert_sync_task(::Actions::Katello::Product::Update) do |product, _product_params|
        assert_equal @product.id, product.id
      end
      put :update, params: { :id => @product.id, :product => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @delete_permission, @create_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => @product.id, :product => {:name => 'New Name'} }
      end
    end

    def test_update_protected_specific_instance
      allowed_perms = [{:name => @update_permission, :search => "name=\"#{@product.name}\"" }]
      denied_perms = [{:name => @update_permission, :search => "name=\"some_name\"" }]

      assert_protected_object(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => @product.id, :product => {:name => 'New Name'} }
      end
    end

    test_attributes :pid => '30df95f5-0a4e-41ee-a99f-b418c5c5f2f3'
    def test_destroy
      assert_async_task ::Actions::Katello::Product::Destroy do |prod|
        assert_equal @product.id, prod.id
      end

      delete :destroy, params: { :id => @product.id }

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@create_permission, @read_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :id => @product.id }
      end
    end

    def test_sync
      assert_async_task(::Actions::BulkAction) do |action_class, _repos|
        assert_equal action_class, ::Actions::Katello::Repository::Sync
      end
      post :sync, params: { :id => @product.id }
      assert_response :success
    end

    def test_sync_bad_product
      product = Product.find(katello_products(:empty_product).id)
      post :sync, params: { :id => product.id }
      assert_response 422
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@read_permission, @update_permission, @delete_permission, @create_permission]

      assert_async_task(::Actions::BulkAction)
      assert_protected_action(:update, allowed_perms, denied_perms) do
        post :sync, params: { :id => @product.id }
      end
    end
  end
end
