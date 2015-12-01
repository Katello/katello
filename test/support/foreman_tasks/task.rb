module Support
  module ForemanTasks
    module Task
      def stub_tasks!
        @controller.stubs(:sync_task).returns(build_task_stub)
        @controller.stubs(:async_task).returns(build_task_stub)
      end

      def build_task_stub
        task_attrs = [:id, :label, :pending,
                      :username, :started_at, :ended_at, :state, :result, :progress,
                      :input, :humanized, :cli_example].inject({}) { |h, k| h.update k => nil }
        task_attrs[:output] = {}

        stub('task', task_attrs).mimic!(::ForemanTasks::Task)
      end

      def assert_async_task(expected_action_class, *args_expected, &block)
        assert_foreman_task(true, expected_action_class, *args_expected, &block)
      end

      def assert_sync_task(expected_action_class, *args_expected, &block)
        assert_foreman_task(false, expected_action_class, *args_expected, &block)
      end

      def assert_foreman_task(async, expected_action_class, *args_expected, &block)
        block      ||= if args_expected.empty?
                         lambda { |*_args| true }
                       else
                         lambda { |*args|  args == args_expected }
                       end

        method = async ? :async_task : :sync_task
        task_stub = build_task_stub
        @controller.
            expects(method).
            with { |action_class, *args| expected_action_class == action_class && block.call(*args) }.
            returns(task_stub)
        return task_stub
      end
    end
  end
end
