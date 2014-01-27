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
      def assert_async_task(expected_action_class, *args_expected, &block)
        task_attrs = [:id, :label, :pending,
                      :username, :started_at, :ended_at, :state, :result, :progress,
                      :input, :output, :humanized, :cli_example].inject({}) { |h, k| h.update k => nil }
        task       = mock('task', task_attrs).mimic!(::ForemanTasks::Task)
        block      ||= if args_expected.empty?
                         -> (*_) { true }
                       else
                         -> (*args) { args == args_expected }
                       end

        @controller.
            expects(:async_task).
            with { |action_class, *args| expected_action_class == action_class && block.call(*args) }.
            returns(task)
      end
    end
  end
end
