#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  action_class = ::Actions::Pulp::Repository::Sync

  describe action_class do
    include Dynflow::Testing

    def progress_hash(left, total)
      { 'task_id'  => '76fb4115-2ec4-4945-815b-0f9d216b4183',
        'progress' => {
            'yum_importer' => {
                'content' => {
                    'size_total' => total,
                    'size_left'  => left } } } }

    end

    it 'runs' do
      User.stubs(:current).returns mock('user', remote_id: 'user')
      action        = create_action action_class
      task1         = { 'tags'    => ['pulp:action:sync'],
                        'task_id' => '76fb4115-2ec4-4945-815b-0f9d216b4183' }
      task2         = task1.merge progress_hash 6, 8
      task3         = task1.merge(progress_hash 0, 8).merge('finish_time' => 'now')
      pulp_response = [task1, { 'task_id' => 'other' }]

      plan_action action, pulp_id: 'pulp-id'
      action = run_action action do |action|
        repository     = mock 'repository',
                              sync: pulp_response
        pulp_resources = mock 'pulp_resources', repository: repository
        action.expects(:pulp_resources).returns(pulp_resources)
        action.
            stubs(:task_resource).
            returns(mock('task_resource').
                        tap { |m| m.expects(:poll).twice.returns(task2, task3) })
      end

      action.external_task.must_equal(task1)
      action.run_progress.must_equal 0.01

      clock_progress action
      action.external_task.must_equal task2
      action.run_progress.must_equal 0.25
      action.wont_be :done?

      clock_progress action
      action.external_task.must_equal task3
      action.run_progress.must_equal 1
      action.must_be :done?
    end
  end
end
