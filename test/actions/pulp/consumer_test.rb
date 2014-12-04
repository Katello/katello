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
  class ConsumerTestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction
    include VCR::TestCase

    let(:uuid) { 'uuid' }
    let(:name) { 'name' }
    let(:type) { 'rpm' }
    let(:args) { %w(vim vi) }

    def setup
      ::ForemanTasks.sync_task(::Actions::Pulp::Consumer::Create, uuid: uuid, name: name)
    end

    def teardown
      configure_runcible
      ::Katello.pulp_server.resources.consumer.delete(uuid)
    rescue RestClient::ResourceNotFound => e
      puts "Failed to delete consumer #{e.message}"
    end

    def it_runs(planned_action, *invocation_method)
      action = run_action planned_action do |actn|
        expectation = runcible_expects(actn, *invocation_method)
        yield expectation, actn if block_given?
        expectation.returns(task_base)
        stub_task_poll actn, task_base.merge(task_finished_hash)
      end

      action.wont_be :done?
      progress_action_time action
      action.must_be :done?
    end
  end

  class ConsumerTest < ConsumerTestBase
    def test_create
      configure_runcible
      consumer = ::Katello.pulp_server.resources.consumer.retrieve(uuid)
      refute_nil consumer
      assert_equal name, consumer[:display_name]
    end

    def test_install_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentInstall)
      it_runs(action, :extensions, :consumer, :install_content)
    end

    def test_update_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentUpdate)
      it_runs(action, :extensions, :consumer, :update_content)
    end

    def test_uninstall_content
      action = plan_consumer_action(::Actions::Pulp::Consumer::ContentUninstall)
      it_runs(action, :extensions, :consumer, :uninstall_content)
    end

    def test_sync_node
      action = create_and_plan_action(::Actions::Pulp::Consumer::SyncNode,
                                      consumer_uuid: uuid,
                                      repo_ids: nil)
      it_runs(action, :extensions, :consumer, :update_content) do |stub|
        stub.with(uuid, 'node', nil, {})
      end

      action = create_and_plan_action(::Actions::Pulp::Consumer::SyncNode,
                                      consumer_uuid: uuid,
                                      repo_ids: nil,
                                      skip_content: true)
      it_runs(action, :extensions, :consumer, :update_content) do |stub|
        stub.with(uuid, 'node', nil, skip_content_update: true)
      end

      action = create_and_plan_action(::Actions::Pulp::Consumer::SyncNode,
                                      consumer_uuid: uuid,
                                      repo_ids: ["1"])
      it_runs(action, :extensions, :consumer, :update_content) do |stub|
        stub.with(uuid, 'repository', ["1"], {})
      end
    end

    def plan_consumer_action(action_class)
      create_and_plan_action(action_class,
                             consumer_uuid: uuid,
                             type: type,
                             args: args)
    end
  end

  class NodeBindingsTest < ConsumerTestBase
    let(:repository) do
      katello_repositories(:fedora_17_x86_64_dev)
    end

    def setup
      ::Katello::RepositorySupport.create_repo(repository.id)
    end

    def teardown
      ::Katello::RepositorySupport.destroy_repo
    end

    def test_bind_node_distributor
      action = create_and_plan_action(::Actions::Pulp::Consumer::BindNodeDistributor,
                                      consumer_uuid: uuid,
                                      repo_id: repository.pulp_id,
                                      bind_options: {})

      it_runs(action, :resources, :consumer, :bind) do |stub|
        stub.with(uuid, repository.pulp_id, "#{repository.pulp_id}_nodes", {})
      end
    end

    def test_unbind_node_distributor
      action = create_and_plan_action(::Actions::Pulp::Consumer::UnbindNodeDistributor,
                                      consumer_uuid: uuid,
                                      repo_id: repository.pulp_id)
      it_runs(action, :resources, :consumer, :unbind) do |stub|
        stub.with(uuid, repository.pulp_id, "#{repository.pulp_id}_nodes")
      end
    end
  end
end
