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
  module Actions
    module PulpTask
      def task_progress_hash(left, total)
        { 'task_id'  => '76fb4115-2ec4-4945-815b-0f9d216b4183',
          'progress_report' => {
              'yum_importer' => {
                  'content' => {
                      'size_total' => total,
                      'size_left'  => left } } } }
      end

      def task_finished_hash
        { 'finish_time' => (Time.now - 5).getgm.iso8601 }
      end

      def task_base(id = '76fb4115-2ec4-4945-815b-0f9d216b4183')
        { 'task_id' => id, 'spawned_tasks' => [] }
      end

      def stub_task_poll(action, *returns)
        task_resource = mock('task_resource').tap do |mock|
          mock.expects(:poll).times(returns.size).returns(*returns)
        end
        action.stubs(:task_resource).returns(task_resource)
      end
    end
  end
end
