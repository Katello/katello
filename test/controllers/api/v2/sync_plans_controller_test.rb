# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SyncPlansControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @sync_plan = Katello::SyncPlan.find(katello_sync_plans(:sync_plan_hourly).id)
      @products = katello_products(:fedora, :redhat, :empty_product)
    end

    def permissions
      @resource_type = "Katello::SyncPlan"
      @view_permission = :view_sync_plans
      @create_permission = :create_sync_plans
      @update_permission = :edit_sync_plans
      @destroy_permission = :destroy_sync_plans

      @sync_permission = :sync_products
      @read_products_permission = :view_products
      @update_products_permission = :edit_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      Repository.any_instance.stubs(:sync_status).returns(PulpSyncStatus.new({}))
      Repository.any_instance.stubs(:last_sync).returns(DateTime.now.to_s)
      models
      permissions
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/sync_plans/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_create
      post :create, :organization_id => @organization.id,
                    :sync_plan => {:name => 'Hourly Sync Plan',
                                   :sync_date => '2014-01-09 17:46:00',
                                   :interval => 'hourly',
                                   :description => 'This is my cool new product.'}

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
    end

    def test_create_fail
      post :create, :organization_id => @organization.id,
                    :sync_plan => {:sync_date => '2014-01-09 17:46:00',
                                   :description => 'This is my cool new sync plan.'}

      assert_response :unprocessable_entity
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, :organization_id => @organization.id,
                      :sync_plan => {:name => 'Hourly Sync Plan',
                                     :sync_date => '2014-01-09 17:46:00',
                                     :interval => 'hourly'}
      end
    end

    def test_update
      put :update, :id => @sync_plan.id, :organization_id => @organization.id,
          :sync_plan => {:name => 'New Name'}

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
      assert_equal assigns[:sync_plan].name, 'New Name'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms, [@organization]) do
        put :update, :id => @sync_plan.id, :organization_id => @organization.id,
            :sync_plan => {:description => 'new description.'}
      end
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::SyncPlan::Destroy) do |sync_plan|
        sync_plan.id.must_equal @sync_plan.id
      end

      delete :destroy, :organization_id => @organization.id, :id => @sync_plan.id

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, :organization_id => @organization.id, :id => @sync_plan.id
      end
    end

    def test_add_products
      product_ids = @products.collect { |p| p.id.to_s }
      ::ForemanTasks.expects(:sync_task).with(::Actions::Katello::SyncPlan::AddProducts, @sync_plan, product_ids)

      put :add_products, :id => @sync_plan.id, :organization_id => @organization.id,
          :product_ids => product_ids

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
    end

    def test_add_products_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:add_products, allowed_perms, denied_perms, [@organization]) do
        put :add_products, :id => @sync_plan.id, :organization_id => @organization.id,
          :product_ids => @products.collect { |p| p.id }
      end
    end

    def test_remove_products
      product_ids = @products.collect { |p| p.id.to_s }
      ::ForemanTasks.expects(:sync_task).with(::Actions::Katello::SyncPlan::RemoveProducts, @sync_plan, product_ids)

      put :remove_products, :id => @sync_plan.id, :organization_id => @organization.id,
          :product_ids => product_ids

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
    end

    def test_remove_products_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:remove_products, allowed_perms, denied_perms, [@organization]) do
        put :remove_products, :id => @sync_plan.id, :organization_id => @organization.id,
            :product_ids => @products.collect { |p| p.id }
      end
    end

    def test_sync
      repo_ids = @sync_plan.products.collect { |product| product.repositories.map(&:id) }
      repo_ids.flatten!

      assert_async_task(::Actions::BulkAction) do |action_class, ids|
        assert_equal action_class, ::Actions::Katello::Repository::Sync
        assert_equal repo_ids, ids
      end

      put :sync, :id => @sync_plan.id, :organization_id => @organization.id

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:sync, allowed_perms, denied_perms, [@organization]) do
        put :sync, :id => @sync_plan.id, :organization_id => @organization.id
      end
    end
  end
end
