require 'katello_test_helper'

module Katello
  class SyncManagementControllerTest < ActionController::TestCase
    def permissions
      @sync_permission = :sync_products
    end

    def build_task_stub
      task_attrs = [:id, :label, :pending, :execution_plan, :resumable?,
                    :username, :started_at, :ended_at, :state, :result, :progress,
                    :input, :humanized, :cli_example].inject({}) { |h, k| h.update k => nil }
      task_attrs[:output] = {}

      stub('task', task_attrs).mimic!(::ForemanTasks::Task)
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
      ForemanTasks.stubs(:async_task).returns(build_task_stub)
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

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index
      end
    end

    def test_sync_status
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.expects(:format_sync_progress).returns({})
      get :sync_status, params: { :repoids => [@repository.id] }

      assert_response :success
    end

    def test_sync_status_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:sync_status, allowed_perms, denied_perms, [@organization]) do
        get :sync_status, params: { :repoids => [@repository.id] }
      end
    end

    def test_sync
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.expects(:sync_repos).returns({})

      post :sync, params: { :repoids => [@repository.id] }

      assert_response :success
    end

    def test_sync_repos
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.expects(:latest_task).returns(:state => 'running')
      @controller.expects(:format_sync_progress).returns('formatted-progress')

      post :sync, params: { :repoids => [@repository.id] }

      assert_response :success
      assert_equal %([\"formatted-progress\"]), @response.body
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:sync, allowed_perms, denied_perms, [@organization]) do
        post :sync, params: { :repoids => [@repository.id] }
      end
    end

    def test_destroy
      Repository.any_instance.expects(:cancel_dynflow_sync)
      delete :destroy, params: { :id => @repository.id }

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, params: { :id => @repository.id }
      end
    end
  end
end
