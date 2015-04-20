#
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

require 'katello_test_helper'

module ::Actions::Pulp::Repository
  class SyncProgressTest < TestBase
    let(:action_class) { ::Actions::Pulp::Repository::Sync }

    before do
      stub_remote_user
      @repo = Katello::Repository.find(katello_repositories(:fedora_17_x86_64))
    end

    it 'runs' do
      action        = create_action action_class
      task1         = task_base.merge('tags'    => ['pulp:action:sync'])
      task2         = task1.merge(task_progress_hash 6, 8)
      task3         = task1.merge(task_progress_hash 0, 8).merge(task_finished_hash)
      pulp_response =  { 'spawned_tasks' => [{'task_id' => 'other' }]}

      plan_action action, pulp_id: @repo.pulp_id
      action = run_action action do |actn|
        runcible_expects(actn, :resources, :repository, :sync).
            returns(pulp_response)
        stub_task_poll actn, task1, task2, task3
      end

      action.external_task[0].must_equal(task1)
      action.run_progress.must_equal 0.01

      progress_action_time action
      action.external_task[0].must_equal task2
      action.run_progress.must_equal 0.25
      action.wont_be :done?

      progress_action_time action
      action.external_task[0].must_equal task3
      action.run_progress.must_equal 1
      action.must_be :done?
    end
  end
end
