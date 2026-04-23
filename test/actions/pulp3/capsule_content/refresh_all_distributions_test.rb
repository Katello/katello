require 'katello_test_helper'

module ::Actions::Pulp3::CapsuleContent
  class RefreshAllDistributionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::CapsuleSupport
    include Support::Actions::RemoteAction

    let(:proxy) { capsule_content.smart_proxy }

    before do
      set_user
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
    end

    it 'plans exactly one RefreshDistribution per repository, no more and no less' do
      repos = [katello_repositories(:pulp3_file_1), katello_repositories(:pulp3_docker_1)]

      tree = plan_action_tree(::Actions::Pulp3::CapsuleContent::RefreshAllDistributions,
                              proxy, repos)

      planned_repo_ids = []
      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal proxy.id, input[:smart_proxy_id]
        planned_repo_ids << input[:repository_id]
      end
      assert_equal repos.map(&:id).sort, planned_repo_ids.sort
    end

    it 'plans nothing when repository list is empty' do
      tree = plan_action_tree(::Actions::Pulp3::CapsuleContent::RefreshAllDistributions,
                              proxy, [])

      refute_tree_planned(tree, ::Actions::Pulp3::CapsuleContent::RefreshDistribution)
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
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
    end

    # pulp3_skip_publication: true — plan_self is skipped, tree is empty
    it 'does not plan RefreshDistribution inline for publication-less repos (e.g. docker)' do
      repo = katello_repositories(:pulp3_docker_1)
      tree = plan_action_tree(::Actions::Pulp3::CapsuleContent::GenerateMetadata,
                              repo, proxy)

      refute_tree_planned(tree, ::Actions::Pulp3::CapsuleContent::RefreshDistribution)
    end

    # pulp3_skip_publication: false — plan_self IS called to create a publication
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
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
    end

    it 'recovers from a concurrent distribution creation by retrying as an update' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )
      action.rescue_external_task(error)
    end

    it 'recovers when both name and base_path are reported as non-unique (real Pulp error format)' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'name': [ErrorDetail(string='This field must be unique.', code='unique')], " \
        "'base_path': [ErrorDetail(string='This field must be unique.', code='unique')]}"
      )
      action.rescue_external_task(error)
    end

    it 'does not attempt recovery for non-Pulp3Errors' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)
      action.expects(:invoke_external_task).never

      action.rescue_external_task(RuntimeError.new("connection refused"))
    end

    it 'recovers from an overlap conflict (base_path overlaps existing distribution)' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)

      mock_task = mock('pulp_task')
      action.expects(:invoke_external_task).returns(mock_task)
      action.expects(:external_task=).with(mock_task)

      error = ::Katello::Errors::Pulp3Error.new(
        "{'base_path': ['Overlaps with existing distribution']}"
      )
      action.rescue_external_task(error)
    end

    it 're-raises Pulp3Errors unrelated to distribution uniqueness' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.stubs(:input).returns('repository_id' => repo.id, 'smart_proxy_id' => proxy.id)
      action.expects(:invoke_external_task).never

      error = ::Katello::Errors::Pulp3Error.new("Remote artifacts cannot be exported")
      assert_raises(::Katello::Errors::Pulp3Error) { action.rescue_external_task(error) }
    end
  end
end
