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

    def test_sync_status_persists_after_task_delete
      # Setup: Sync the repository to create an audit record
      @repository.audit_sync

      # Delete all sync tasks to simulate task cleanup
      ForemanTasks::Task.where(
        label: ::Actions::Katello::Repository::Sync.name
      ).for_resource(@repository).destroy_all

      # Clear memoization
      @repository.instance_variable_set(:@latest_dynflow_sync, nil)

      # Verify task is deleted but audit exists
      assert_nil @repository.latest_dynflow_sync
      assert_not_nil @repository.latest_sync_audit

      # Call the controller
      get :poll, params: { :repository_ids => [@repository.id], :organization_id => @organization.id }

      assert_response :success
      result = JSON.parse(@response.body)

      # Should show "Syncing Complete" not "Never Synced"
      assert_equal 1, result.length
      assert_equal 'stopped', result[0]['raw_state']
      assert_equal 'Syncing Complete.', result[0]['state']
      assert_not_nil result[0]['start_time']
    end
  end
end
