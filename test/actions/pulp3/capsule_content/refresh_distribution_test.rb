require 'katello_test_helper'

module ::Actions::Pulp3::CapsuleContent
  class DistributionConflictTest < ActiveSupport::TestCase
    it 'matches both async task and direct api race messages' do
      async_error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )
      api_error = RuntimeError.new('{"base_path":["Overlaps with existing distribution"]}')

      assert ::Katello::Pulp3::DistributionConflict.create_race?(async_error)
      assert ::Katello::Pulp3::DistributionConflict.create_race?(api_error)
      refute ::Katello::Pulp3::DistributionConflict.create_race?("Remote artifacts cannot be exported")
    end
  end

  class GenerateMetadataTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::CapsuleSupport
    include Support::Actions::RemoteAction

    let(:proxy) { capsule_content.smart_proxy }

    before do
      set_user
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
    end

    it 'does not plan RefreshDistribution inline for publication-less repos (e.g. docker)' do
      repo = katello_repositories(:pulp3_docker_1)
      tree = plan_action_tree(::Actions::Pulp3::CapsuleContent::GenerateMetadata,
                              repo, proxy)

      refute_tree_planned(tree, ::Actions::Pulp3::CapsuleContent::RefreshDistribution)
    end

    it 'does not plan RefreshDistribution inline for publication-based repos (e.g. file)' do
      repo = katello_repositories(:pulp3_file_1)
      tree = plan_action_tree(::Actions::Pulp3::CapsuleContent::GenerateMetadata,
                              repo, proxy)

      refute_tree_planned(tree, ::Actions::Pulp3::CapsuleContent::RefreshDistribution)
    end
  end

  class RefreshDistributionTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::CapsuleSupport
    include Support::Actions::RemoteAction

    let(:proxy) { capsule_content.smart_proxy }
    let(:repo) { katello_repositories(:pulp3_docker_1) }

    before do
      set_user
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
    end

    def build_action_with_output
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)
      action_output = {}
      action.stubs(:output).returns(action_output)
      [action, action_output]
    end

    it 'recovers from a concurrent distribution creation by retrying as an update' do
      action, action_output = build_action_with_output

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )
      action.rescue_external_task(error)
      assert action_output[:retried_distribution_refresh]
    end

    it 'recovers when both name and base_path are reported as non-unique (real Pulp error format)' do
      action, action_output = build_action_with_output

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'name': [ErrorDetail(string='This field must be unique.', code='unique')], " \
        "'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )
      action.rescue_external_task(error)
      assert action_output[:retried_distribution_refresh]
    end

    # Non-Pulp3Errors fall through to the parent's rescue_external_task,
    # which delegates to Dynflow's default handler. We verify here that
    # RefreshDistribution does not intercept them for its own retry logic.
    it 'does not attempt recovery for non-Pulp3Errors' do
      action, _action_output = build_action_with_output
      action.expects(:invoke_external_task).never

      action.rescue_external_task(RuntimeError.new("connection refused"))
    end

    it 'recovers from an overlap conflict (base_path overlaps existing distribution)' do
      action, action_output = build_action_with_output

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': ['Overlaps with existing distribution']}"
      )
      action.rescue_external_task(error)
      assert action_output[:retried_distribution_refresh]
    end

    it 're-raises the conflict after the one allowed retry is exhausted' do
      action, action_output = build_action_with_output
      action_output[:retried_distribution_refresh] = true
      action.expects(:invoke_external_task).never

      error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )

      assert_raises(::Katello::Errors::Pulp3Error) { action.rescue_external_task(error) }
    end

    it 're-raises Pulp3Errors unrelated to distribution uniqueness' do
      action, _action_output = build_action_with_output
      action.expects(:invoke_external_task).never

      error = ::Katello::Errors::Pulp3Error.new("Remote artifacts cannot be exported")
      assert_raises(::Katello::Errors::Pulp3Error) { action.rescue_external_task(error) }
    end
  end

  class RefreshAllDistributionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::CapsuleSupport

    let(:action_class) { ::Actions::Pulp3::CapsuleContent::RefreshAllDistributions }

    def setup
      set_user
    end

    def test_plans_refresh_for_each_repo
      proxy = capsule_content.smart_proxy
      yum = katello_repositories(:fedora_17_x86_64)
      file = katello_repositories(:pulp3_file_1)
      action = create_action(action_class)
      plan_action(action, proxy, [yum, file])

      assert_action_planned_with action, ::Actions::Pulp3::CapsuleContent::RefreshDistribution, yum, proxy
      assert_action_planned_with action, ::Actions::Pulp3::CapsuleContent::RefreshDistribution, file, proxy
    end

    def test_empty_list_is_a_noop
      proxy = capsule_content.smart_proxy
      action = create_action(action_class)
      plan_action(action, proxy, [])
      refute_action_planned action, ::Actions::Pulp3::CapsuleContent::RefreshDistribution
    end
  end
end
