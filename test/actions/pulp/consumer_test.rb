require 'katello_test_helper'

module ::Actions::Pulp
  class ConsumerTestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction
    include VCR::TestCase

    let(:uuid) { 'uuid' }
    let(:consumer_name) { 'gregor' }
    let(:type) { 'rpm' }
    let(:args) { %w(vim vi) }

    def setup
      set_user
      ::ForemanTasks.sync_task(::Actions::Pulp::Consumer::Create, uuid: uuid, name: consumer_name)
    end

    def teardown
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
      consumer = ::Katello.pulp_server.resources.consumer.retrieve(uuid)
      refute_nil consumer
      assert_equal consumer_name, consumer[:display_name]
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

    def test_regenerate_applicability
      action = create_and_plan_action(::Actions::Pulp::Consumer::GenerateApplicability,
                                      uuids: [uuid],
                                      type: type,
                                      args: args)
      it_runs(action, :resources, :consumer, :regenerate_applicability_by_id)
    end

    def test_regenerate_applicability_multiple_uuid
      action = create_and_plan_action(::Actions::Pulp::Consumer::GenerateApplicability,
                                      uuids: [uuid, 'another-uuid'],
                                      type: type,
                                      args: args)
      it_runs(action, :extensions, :consumer, :regenerate_applicability_by_ids)
    end

    def plan_consumer_action(action_class)
      create_and_plan_action(action_class,
                             consumer_uuid: uuid,
                             type: type,
                             args: args)
    end
  end
end
