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

module ::Actions::Pulp

  class ConsumerTest < VCR::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction

    let(:uuid) { 'uuid' }
    let(:name) { 'name' }
    let(:type) { 'rpm' }
    let(:args) { %w(vim vi) }

    def setup
      ::ForemanTasks.sync_task(::Actions::Pulp::Consumer::Create, uuid: uuid, name: name)
    end

    def teardown
      configure_runcible
      consumer = ::Katello.pulp_server.resources.consumer.delete(uuid)
    rescue RestClient::ResourceNotFound => e
    end

    def test_create
      configure_runcible
      consumer = ::Katello.pulp_server.resources.consumer.retrieve(uuid)
      refute_nil consumer
      assert_equal name, consumer[:display_name]
    end

    def test_install_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentInstall)
      it_runs(action, :install_content)
    end

    def test_update_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentUpdate)
      it_runs(action, :update_content)
    end

    def test_uninstall_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentUninstall)
      it_runs(action, :uninstall_content)
    end

    def plan_consumer_action(action_class)
      create_and_plan_action(action_class,
                             consumer_uuid: uuid,
                             type: type,
                             args: args
                            )
    end

    def it_runs(planned_action, invocation_method)
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
end
