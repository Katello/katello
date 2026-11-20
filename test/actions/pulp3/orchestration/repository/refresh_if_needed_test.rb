require 'katello_test_helper'

module ::Actions::Pulp3::Orchestration::Repository
  class RefreshIfNeededTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    def setup
      stub_remote_user
      @repo = katello_repositories(:busybox)
      @proxy = SmartProxy.pulp_primary
      @service = ::Katello::Pulp3::Repository::Docker
      ::Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).destroy_all
      @reference = ::Katello::Pulp3::DistributionReference.create!(repository_id: @repo.id,
        href: '/pulp/distributions/old/', path: 'old/path')
    end

    def refresh
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded, @repo, @proxy)
    end

    def stub_distribution(path)
      @service.any_instance.stubs(:read_distribution).with(@reference.href).returns(
        stub(base_path: path, content_guard: nil, prn: 'prn:container.containerdistribution:abc'))
    end

    def completed_task(state = 'completed', created_resources = [])
      data = { 'pulp_href' => '/pulp/api/v3/tasks/123/', 'state' => state,
               'created_resources' => created_resources, 'task_group' => nil }
      data['error'] = { 'description' => 'update failed' } if state == 'failed'
      stub(as_json: data)
    end

    def test_pattern_update_reconciles_after_completed_task_without_second_patch
      @repo.environment.update_column(:registry_name_pattern, '<%= repository.label %>/changed')
      @repo.reload
      @repo.set_container_repository_name
      new_path = @repo.container_repository_name
      @repo.update_column(:container_repository_name, new_path)
      @service.any_instance.expects(:update_remote).once.returns(completed_task)
      @service.any_instance.expects(:distribution_needs_update?).once.returns(true)
      @service.any_instance.expects(:update_distribution).once.returns([completed_task])
      expectation = @service.any_instance.expects(:read_distribution).with do |href|
        assert_equal @reference.href, href
        assert_equal 'old/path', @reference.reload.path
        true
      end
      expectation.returns(stub(base_path: new_path, content_guard: nil, prn: 'prn:container.containerdistribution:abc'))

      task = refresh

      assert_equal 'success', task.result
      assert_equal 2, task.output[:pulp_tasks].size
      assert_equal 'completed', task.output[:pulp_tasks].last[:state]
      assert_equal new_path, @reference.reload.path
      assert_equal '/pulp/distributions/old/', @reference.href
    end

    def test_remote_created_resource_is_not_treated_as_distribution
      remote_href = '/pulp/api/v3/remotes/container/container/123/'
      @service.any_instance.expects(:update_remote).once.returns(completed_task('completed', [remote_href]))
      @service.any_instance.expects(:distribution_needs_update?).once.returns(true)
      @service.any_instance.expects(:update_distribution).once.returns([completed_task])
      @service.any_instance.expects(:read_distribution).once.with(@reference.href).returns(
        stub(base_path: 'new/path', content_guard: nil, prn: 'prn:container.containerdistribution:abc'))

      task = refresh

      assert_equal 'success', task.result
      assert_equal 2, task.output[:pulp_tasks].size
      assert_equal [remote_href], task.output[:pulp_tasks].first[:created_resources]
      assert_equal 'new/path', @reference.reload.path
      assert_equal '/pulp/distributions/old/', @reference.href
    end

    def test_noop_reconciles_existing_reference
      @service.any_instance.expects(:update_remote).once.returns(nil)
      @service.any_instance.expects(:distribution_needs_update?).once.returns(false)
      @service.any_instance.expects(:update_distribution).never
      stub_distribution('new/path')

      task = refresh

      assert_empty task.output[:pulp_tasks]
      assert_equal 'new/path', @reference.reload.path
    end

    def test_noop_patch_reconciles_existing_reference
      @service.any_instance.expects(:update_remote).once.returns(nil)
      @service.any_instance.expects(:distribution_needs_update?).once.returns(true)
      @service.any_instance.expects(:update_distribution).once.returns([])
      stub_distribution('new/path')

      task = refresh

      assert_empty task.output[:pulp_tasks]
      assert_equal 'new/path', @reference.reload.path
    end

    def test_no_reference_and_no_tasks_does_not_attempt_reconciliation
      @reference.destroy!
      @service.any_instance.expects(:update_remote).once.returns(nil)
      @service.any_instance.expects(:distribution_needs_update?).once.returns(false)
      @service.any_instance.expects(:update_distribution).never
      @service.any_instance.expects(:read_distribution).never

      task = refresh

      assert_empty task.output[:pulp_tasks]
      assert_nil ::Katello::Pulp3::DistributionReference.find_by(repository_id: @repo.id)
    end

    def test_failed_pulp_task_does_not_reconcile
      @service.any_instance.expects(:update_remote).once.returns(nil)
      @service.any_instance.expects(:distribution_needs_update?).once.returns(true)
      @service.any_instance.expects(:update_distribution).once.returns([completed_task('failed')])
      @service.any_instance.expects(:read_distribution).never

      assert_raises(::ForemanTasks::TaskError) { refresh }
      assert_equal 'old/path', @reference.reload.path
    end

    def test_secondary_docker_does_not_plan_reconciliation
      @proxy.stubs(:pulp_primary?).returns(false)
      action = create_and_plan_action(::Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded, @repo, @proxy)
      refute_action_planned action, ::Actions::Pulp3::Repository::SaveDistributionReferences
      assert_equal @repo.id, action.input[:repository_id]
    end

    def test_non_docker_does_not_plan_reconciliation
      repo = katello_repositories(:fedora_17_x86_64_duplicate)
      action = create_and_plan_action(::Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded, repo, @proxy)
      refute_action_planned action, ::Actions::Pulp3::Repository::SaveDistributionReferences
      assert_equal repo.id, action.input[:repository_id]
    end
  end
end
