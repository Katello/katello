require 'katello_test_helper'

module ::Actions::Katello::CapsuleContent
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::CapsuleSupport
    include Support::Actions::RemoteAction

    let(:environment) do
      katello_environments(:library)
    end

    let(:repository) do
      katello_repositories(:fedora_17_x86_64_dev)
    end

    let(:custom_repository) do
      katello_repositories(:fedora_17_x86_64)
    end

    before do
      set_user
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
    end
  end

  class RemoveOrphansPlanTest < TestBase
    let(:action_class) { ::Actions::Katello::OrphanCleanup::RemoveOrphans }

    it 'plans proxy orphans cleanup with pulp3 master' do
      smart_proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      tree = plan_action_tree(action_class, smart_proxy)

      assert_tree_planned_with(tree, ::Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions) do |input|
        assert_equal smart_proxy.id, input[:smart_proxy_id]
      end
    end

    it 'plans proxy orphans cleanup with pulp3 mirror' do
      smart_proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)
      tree = plan_action_tree(action_class, smart_proxy)

      assert_tree_planned_with(tree, ::Actions::Pulp3::OrphanCleanup::RemoveUnneededRepos) do |input|
        assert_equal smart_proxy.id, input[:smart_proxy_id]
      end
    end
  end

  class RemoveUnneededReposTest < TestBase
    let(:action_class) { ::Actions::Pulp::OrphanCleanup::RemoveUnneededRepos }

    it "plans removal of unneeded repos" do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([])
      action = create_action(action_class)
      action.expects(:plan_self)
      plan_action(action, capsule_content.smart_proxy)
    end
  end

  class RemoveOrphansTest < TestBase
    let(:action_class) { ::Actions::Pulp::Orchestration::OrphanCleanup::RemoveOrphans }
    it "Calls remove uneeded repos" do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([])
      action = create_action(action_class)
      plan_action(action, capsule_content.smart_proxy)
      assert_action_planed(action, ::Actions::Pulp::OrphanCleanup::RemoveUnneededRepos)
      assert_action_planed(action, ::Actions::Pulp::OrphanCleanup::RemoveOrphans)
    end
  end
end
