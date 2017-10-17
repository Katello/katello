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
      Product.any_instance.stubs('productContent').returns([])
      Product.any_instance.stubs('sync_status').returns(PulpSyncStatus.new)
    end

    def permissions
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
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/products/index'
    end

    def test_index_name
      get :index, :organization_id => @organization.id, :name => @product.name

      assert_response :success
      assert_template 'api/v2/products/index'
    end

    def test_index_available_for
      sync_plan = SyncPlan.first
      @product.update_attribute(:sync_plan_id, sync_plan.id)
      get :index, :organization_id => @organization.id, :available_for => 'sync_plan',
        :sync_plan_id => sync_plan.id

      ids = JSON.parse(response.body)['results'].map { |prod| prod['id'] }

      assert_response :success
      assert_template 'api/v2/products/index'

      refute_includes ids, @product.id
    end

    def test_index_protected
      allowed_perms = [@read_permission, @sync_plan_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_create
      product_params = {
        :name => 'fedora product',
        :description => 'this is my cool new product.'
      }
      Api::V2::ProductsController.any_instance.expects(:sync_task).with do |action_class, prod, org|
        action_class.must_equal ::Actions::Katello::Product::Create
        prod.must_be_kind_of(Product)
        org.must_equal @organization
        prod.provider = @provider
      end

      post :create, :product => product_params, :organization_id => @organization.id

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
        post :create, :product => {:name => "foo"}, :organization_id => @organization.id
      end
    end

    def test_create_with_bad_org
      product_params = {
        :name => 'fedora product',
        :description => 'this is my cool new product.'
      }
      post :create, :product => product_params, :organization_id => 'asdfdsafds'

      assert_response 404
    end

    def test_show
      get :show, :id => @product.id

      assert_response :success
      assert_template 'api/v2/products/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@update_permission, @create_permission, @delete_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @product.id
      end
    end

    def test_update
      params = {:name => 'New Name'}
      assert_sync_task(::Actions::Katello::Product::Update) do |product, product_params|
        product.id.must_equal @product.id
        product_params.key?(:name).must_equal true
        product_params[:name].must_equal params[:name]
      end
      put :update, :id => @product.id, :product => params

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_sync_plan
      sync_plan = katello_sync_plans(:sync_plan_hourly)
      params = {:sync_plan_id => sync_plan.id}
      assert_sync_task(::Actions::Katello::Product::Update) do |product, _product_params|
        product.id.must_equal @product.id
      end
      put :update, :id => @product.id, :product => params

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @delete_permission, @create_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @product.id, :product => {:name => 'New Name'}
      end
    end

    def test_destroy
      assert_async_task ::Actions::Katello::Product::Destroy do |prod|
        prod.id.must_equal @product.id
      end

      delete :destroy, :id => @product.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@create_permission, @read_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @product.id
      end
    end

    def test_sync
      assert_async_task(::Actions::BulkAction) do |action_class, _repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
      end
      post :sync, :id => @product.id
      assert_response :success
    end

    def test_sync_bad_product
      product = Product.find(katello_products(:empty_product).id)
      post :sync, :id => product.id
      assert_response 422
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@read_permission, @update_permission, @delete_permission, @create_permission]

      assert_async_task(::Actions::BulkAction)
      assert_protected_action(:update, allowed_perms, denied_perms) do
        post :sync, :id => @product.id
      end
    end
  end
end
