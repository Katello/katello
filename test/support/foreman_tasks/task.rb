# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
                      :input, :output, :humanized, :cli_example].inject({}) { |h, k| h.update k => nil }
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
