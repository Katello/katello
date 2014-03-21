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

module ::Actions::Pulp::Consumer

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction

    before do
      stub_remote_user
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Pulp::Consumer::Create }
    let(:planned_action) do
      create_and_plan_action action_class, uuid: 'uuid', name: 'name'
    end

    it 'runs' do
      run_action planned_action do |action|
        runcible_expects(action, :extensions, :consumer, :create).
            with('uuid', display_name: 'name')
      end
    end
  end


  class ContentTestBase < TestBase
    let(:planned_action) do
      create_and_plan_action action_class,
          consumer_uuid: 'uuid',
          type:          'rpm',
          args:          %w(vim vi)
    end

    let(:action_class) { raise NotImplementedError }

    def it_runs(invocation_method)
      action = run_action planned_action do |action|
        runcible_expects(action, :extensions, :consumer, invocation_method).
            returns(task_base)
        stub_task_poll action, task_base.merge(task_finished_hash)
      end

      action.wont_be :done?
      progress_action_time action
      action.must_be :done?
    end
  end

  class ContentInstallTest < ContentTestBase
    let(:action_class) { ::Actions::Pulp::Consumer::ContentInstall }

    it 'runs' do
      it_runs :install_content
    end
  end

  class ContentUninstallTest < ContentTestBase
    let(:action_class) { ::Actions::Pulp::Consumer::ContentUninstall }

    it 'runs' do
      it_runs :uninstall_content
    end
  end
end
