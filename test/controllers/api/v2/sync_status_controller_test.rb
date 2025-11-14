require 'katello_test_helper'

module Katello
  class Api::V2::SyncStatusControllerTest < ActionController::TestCase
    def models
      @organization = get_organization
      @repository = katello_repositories(:fedora_17_x86_64)
      @product = katello_products(:fedora)
    end

    def permissions
      @sync_permission = :sync_products
    end

    def build_task_stub
      task_attrs = [:id, :label, :pending, :execution_plan, :resumable?,
                    :username, :started_at, :ended_at, :state, :result, :progress,
                    :input, :humanized, :cli_example, :errors].inject({}) { |h, k| h.update k => nil }
      task_attrs[:output] = {}
      stub('task', task_attrs).mimic!(::ForemanTasks::Task)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      models
      permissions
      ForemanTasks.stubs(:async_task).returns(build_task_stub)
    end

    def test_index
      @controller.expects(:collect_repos).returns([])
      @controller.expects(:collect_all_repo_statuses).returns({})

      get :index, params: { :organization_id => @organization.id }

      assert_response :success
    end

    def test_poll
      @controller.expects(:format_sync_progress).returns({})

      get :poll, params: { :repository_ids => [@repository.id], :organization_id => @organization.id }

      assert_response :success
    end

    def test_sync
      @controller.expects(:latest_task).returns(nil)
      @controller.expects(:format_sync_progress).returns({})

      post :sync, params: { :repository_ids => [@repository.id], :organization_id => @organization.id }

      assert_response :success
    end

    def test_destroy
      Repository.any_instance.expects(:cancel_dynflow_sync)

      delete :destroy, params: { :id => @repository.id }

      assert_response :success
    end
  end
end
