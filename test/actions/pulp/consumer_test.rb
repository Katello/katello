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
  namespace = ::Actions::Pulp::Consumer

  describe namespace do
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction

    before do
      stub_remote_user
    end

    let(:action_class) { raise NotImplementedError }
    let(:planned_action) do
      create_and_plan_action action_class,
                             consumer_uuid: 'uuid',
                             type:          'rpm',
                             args:          %w(vim vi)
    end

    def it_runs(invocation_method)
      action = run_action planned_action do |action|
        consumer        = mock('consumer', invocation_method => task_base)
        pulp_extensions = mock 'pulp_extensions', consumer: consumer
        action.expects(:pulp_extensions).returns(pulp_extensions)
        stub_task_poll action, task_base.merge(task_finished_hash)
      end

      action.wont_be :done?
      progress_action_time action
      action.must_be :done?
    end

    describe 'ContentInstall' do
      let(:action_class) { namespace::ContentInstall }

      it 'runs' do
        it_runs :install_content
      end
    end

    describe 'ContentInstall' do
      let(:action_class) { namespace::ContentUninstall }

      it 'runs' do
        it_runs :uninstall_content
      end
    end

  end

end
