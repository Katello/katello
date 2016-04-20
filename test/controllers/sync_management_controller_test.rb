require 'katello_test_helper'

module Katello
  class SyncManagementControllerTest < ActionController::TestCase
    def permissions
      @sync_permission = :sync_products
    end

    def models
      @organization = get_organization
      set_organization(@organization)
      @repository = katello_repositories(:fedora_17_x86_64)
    end

    def setup
      setup_controller_defaults
      login_user(User.find(users(:admin).id))
      models
      permissions
    end

    def test_index
      @controller.expects(:collect_repos).returns({})
      @controller.expects(:get_product_info).at_least_once.returns({})

      get :index

      assert_response :success
    end

    def test_index_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index
      end
    end

    def test_sync_status
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.expects(:format_sync_progress).returns({})
      get :sync_status, :repoids => [@repository.id]

      assert_response :success
    end

    def test_sync_status_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:sync_status, allowed_perms, denied_perms) do
        get :sync_status, :repoids => [@repository.id]
      end
    end

    def test_sync
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.expects(:sync_repos).returns({})

      post :sync, :repoids => [@repository.id]

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, :repoids => [@repository.id]
      end
    end

    def test_destroy
      Repository.any_instance.expects(:cancel_dynflow_sync)
      delete :destroy, :id => @repository.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @repository.id
      end
    end
  end
end
