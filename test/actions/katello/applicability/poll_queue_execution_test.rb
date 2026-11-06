require 'katello_test_helper'

module Actions::Katello::Applicability::Hosts
  class PollQueueExecutionTest < ActiveSupport::TestCase
    self.use_transactional_tests = false
    self.pre_loaded_fixtures = false

    def setup
      @plan_ids = []
      ::Katello::HostQueueElement.delete_all
      # Reuse the configured test database, not Dynflow's SQLite default.
      config = Dynflow::Config.new
      config.persistence_adapter = ForemanTasks.dynflow.world.persistence.adapter
      config.transaction_adapter = ForemanTasks.dynflow.world.transaction_adapter
      config.logger_adapter = Dynflow::Testing.logger_adapter
      config.executor = false
      config.delayed_executor = nil
      config.auto_execute = false
      config.auto_rescue = false
      config.auto_validity_check = false
      config.auto_terminate = false
      config.exit_on_terminate = false
      @world = Dynflow::Testing::InThreadWorld.new(config)
      @world.executor.stubs(:clock_tick)
      @plan_id = nil
    end

    def teardown
      @plan_ids&.each do |plan_id|
        plan = @world.persistence.load_execution_plan(plan_id)
        cancel_consumer(plan) if plan.cancellable?
      end
      if @world
        termination = Concurrent::Promises.resolvable_future
        @world.terminate(termination)
        assert termination.wait(5), 'Dynflow test world termination timed out'
        termination.value!
      end
    ensure
      @world.persistence.delete_execution_plans(uuid: @plan_ids) if @world && @plan_ids&.any?
      ::Katello::HostQueueElement.delete_all
    end

    def trigger_consumer
      result = @world.trigger(PollQueue)
      @plan_ids << result.id
      result
    end

    def start_consumer
      result = trigger_consumer
      assert result.triggered?
      @plan_id = result.id
      @world.persistence.load_execution_plan(@plan_id)
    end

    def cancel_consumer(plan)
      results = plan.cancel
      @world.executor.process_work_items
      results.each { |result| result.value!(5) }
    end

    def test_persisted_consumer_waits_then_dispatches_one_cross_request_batch
      ::Katello::ApplicableHostQueue.push_hosts([1])
      ::Katello::ApplicableHostQueue.push_hosts([1, 2])
      ::ForemanTasks.expects(:async_task).with(BulkGenerate, host_ids: [1, 2])

      plan = start_consumer

      assert_equal :running, plan.state
      assert_equal 3, ::Katello::ApplicableHostQueue.queue_depth
      refute ::ForemanTasks::Task.exists?(external_id: @plan_id)
      assert_equal 1, @world.clock.pending_pings.length

      @world.clock.progress
      @world.executor.process_work_items

      assert_equal 0, ::Katello::ApplicableHostQueue.queue_depth
      assert_equal 1, @world.clock.pending_pings.length
      assert_equal :running, @world.persistence.load_execution_plan(@plan_id).state
    end

    def test_coordinator_rejects_a_second_consumer
      start_consumer

      duplicate = trigger_consumer

      assert_kind_of Dynflow::World::PlaningFailed, duplicate
    end

    def test_resume_uses_saved_polling_state_and_pending_queue
      plan = start_consumer
      step = plan.steps_in_state(:suspended).first
      ::Katello::ApplicableHostQueue.push_hosts([1])
      ::ForemanTasks.expects(:async_task).with(BulkGenerate, host_ids: [1])

      event = @world.event(@plan_id, step.id, nil)
      @world.executor.process_work_items
      event.value!(5)

      assert_equal 0, ::Katello::ApplicableHostQueue.queue_depth
      assert_equal :running, @world.persistence.load_execution_plan(@plan_id).state
    end

    def test_cancellation_preserves_work_and_allows_a_new_consumer
      ::Katello::ApplicableHostQueue.push_hosts([1])
      plan = start_consumer
      cancel_consumer(plan)

      assert_equal :stopped, @world.persistence.load_execution_plan(@plan_id).state
      assert_equal 1, ::Katello::ApplicableHostQueue.queue_depth

      start_consumer
    end
  end
end
