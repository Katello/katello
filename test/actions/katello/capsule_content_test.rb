require 'katello_test_helper'

module ::Actions::Katello::CapsuleContent
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods
    include Support::CapsuleSupport
    include Support::Actions::RemoteAction

    let(:environment) do
      katello_environments(:library)
    end

    let(:repository) do
      katello_repositories(:fedora_17_x86_64_dev)
    end

    before do
      set_user
      @capsule_system = create(:katello_system,
                               :capsule,
                               name: proxy_with_pulp.name,
                               capsule: proxy_with_pulp,
                               environment: environment,
                               content_view: katello_content_views(:library_dev_view))
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::Sync }
    let(:staging_environment) { katello_environments(:staging) }
    let(:dev_environment) { katello_environments(:dev) }

    it 'plans' do
      capsule_content.add_lifecycle_environment(environment)
      action = create_and_plan_action(action_class, capsule_content)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::SyncNode) do |(input)|
        input.must_equal(consumer_uuid: @capsule_system.uuid,
                         repo_ids: capsule_content.pulp_repos.map(&:pulp_id))
      end
    end

    it 'allows limiting scope of the syncing to one environment' do
      capsule_content.add_lifecycle_environment(dev_environment)
      action = create_and_plan_action(action_class, capsule_content, :environment => dev_environment)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::SyncNode) do |(input)|
        input[:repo_ids].size.must_equal 6
      end
    end
    it 'fails when trying to sync to the default capsule' do
      Katello::CapsuleContent.any_instance.stubs(:default_capsule?).returns(true)
      assert_raises(RuntimeError) do
        create_and_plan_action(action_class, capsule_content, :environment => environment)
      end
    end
    it 'fails when trying to sync a lifecyle environment that is not attached' do
      capsule_content.add_lifecycle_environment(environment)

      Katello::CapsuleContent.any_instance.stubs(:lifecycle_environments).returns([])
      assert_raises(RuntimeError) do
        create_and_plan_action(action_class, capsule_content, :environment => staging_environment)
      end
    end
  end

  class UpdateWithoutContentTest < TestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::UpdateWithoutContent }

    it 'plans' do
      capsule_content.add_lifecycle_environment(environment)

      action = create_and_plan_action(action_class, environment)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::SyncNode) do |(input)|
        input.must_equal(consumer_uuid: @capsule_system.uuid, skip_content: true)
      end
    end
  end

  class RepositoryTestBase < TestBase
    include VCR::TestCase
    include FactoryGirl::Syntax::Methods

    def setup
      ::Katello::RepositorySupport.create_repo(repository.id)
    end

    def teardown
      ::Katello::RepositorySupport.destroy_repo
    end
  end

  class ManageBoundRepositoriesAddTest < RepositoryTestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::ManageBoundRepositories }

    before do
      ::Katello::System.any_instance.stubs(:bound_node_repos).returns([])
      capsule_content.add_lifecycle_environment(repository.environment)
    end

    it 'plans' do
      action = create_and_plan_action(action_class, capsule_content)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::BindNodeDistributor,
                                consumer_uuid: @capsule_system.uuid,
                                repo_id: repository.pulp_id,
                                bind_options: { notify_agent: false, binding_config: { strategy: 'mirror' }})
    end
  end

  class ManageBoundRepositoriesRemoveTest < RepositoryTestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::ManageBoundRepositories }

    before do
      ::Katello::System.any_instance.stubs(:bound_node_repos).returns([repository.pulp_id])
    end

    it 'plans' do
      action = create_and_plan_action(action_class, capsule_content)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::UnbindNodeDistributor,
                                consumer_uuid: @capsule_system.uuid,
                                repo_id: repository.pulp_id)
    end
  end
end
