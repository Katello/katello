require 'katello_test_helper'

module Actions::Katello::Applicability::Hosts
  class PollQueueTest < ActiveSupport::TestCase
    include Dynflow::Testing

    def setup
      @action = create_action(PollQueue)
    end

    def test_initial_run_waits_before_collecting_uploads
      ::Katello::ApplicableHostQueue.expects(:dispatch_batches).never

      assert @action.invoke_external_task
      assert_equal [3], @action.poll_intervals
      refute @action.done?
    end

    def test_submits_collected_batches
      ::User.expects(:as_anonymous_admin).yields
      ::Katello::ApplicableHostQueue.expects(:dispatch_batches).yields([1, 2])
      ::ForemanTasks.expects(:async_task).with(BulkGenerate, host_ids: [1, 2])

      assert @action.poll_external_task
    end

    def test_scheduler_failure_does_not_stop_polling
      ::User.expects(:as_anonymous_admin).yields
      ::Katello::ApplicableHostQueue.expects(:dispatch_batches).raises(RuntimeError, 'database unavailable')
      logger = mock
      @action.stubs(:action_logger).returns(logger)
      logger.expects(:error).with('Applicability queue dispatch failed: database unavailable')

      assert @action.poll_external_task
      refute @action.done?
    end

    def test_does_not_create_a_permanently_running_foreman_task
      refute_includes PollQueue.ancestors, ::Actions::TaskSynchronization
      assert_includes PollQueue.ancestors, ::Dynflow::Action::Singleton
    end

    def test_existing_consumer_is_reused
      filter = Dynflow::Coordinator::SingletonActionLock.unique_filter(PollQueue.name)
      coordinator = mock
      coordinator.expects(:find_locks).with(filter).returns([:existing])
      world = stub(coordinator: coordinator)
      world.expects(:trigger).never

      PollQueue.start(world)
    end

    def test_starts_consumer_when_no_execution_plan_exists
      coordinator = stub(find_locks: [])
      world = stub(coordinator: coordinator)
      world.expects(:trigger).with(PollQueue).returns(stub)

      PollQueue.start(world)
    end

    def test_concurrent_start_is_guarded_by_the_dynflow_singleton
      coordinator = mock
      coordinator.expects(:find_locks).twice.returns([], [:another_consumer])
      error = RuntimeError.new('Already active')
      world = stub(coordinator: coordinator)
      world.expects(:trigger).with(PollQueue).returns(Dynflow::World::PlaningFailed['competing-plan', error])

      PollQueue.start(world)
    end

    def test_unexpected_planning_failure_is_not_hidden
      coordinator = stub(find_locks: [])
      error = RuntimeError.new('Cannot persist execution plan')
      world = stub(coordinator: coordinator)
      world.expects(:trigger).with(PollQueue).returns(Dynflow::World::PlaningFailed['failed-plan', error])

      assert_raises(RuntimeError) { PollQueue.start(world) }
    end

    def test_recovered_plan_checks_pending_work_again
      @action.stubs(:output).returns(task: true)
      @action.expects(:poll_external_task).returns(true)

      @action.resume_external_action
    end

    def test_cancellation_releases_consumer_without_touching_queued_work
      ::Katello::ApplicableHostQueue.expects(:dispatch_batches).never
      @action.expects(:singleton_unlock!)

      @action.cancel!
    end
  end
end
