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

    it 'plans proxy orphans cleanup and content unit orphan cleanup on pulp3 primary' do
      smart_proxy = SmartProxy.pulp_primary
      tree = plan_action_tree(action_class, smart_proxy)

      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions)
      assert_tree_planned_with(tree, ::Actions::Katello::OrphanCleanup::RemoveOrphanedContentUnits)
    end

    it 'plans proxy orphans cleanup without content unit orphan cleanup on pulp3 mirror' do
      smart_proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)
      smart_proxy.stubs(:pulp_primary?).returns(false)
      tree = plan_action_tree(action_class, smart_proxy)

      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanDistributions)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRemotes)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions)
      refute_tree_planned(tree, ::Actions::Katello::OrphanCleanup::RemoveOrphanedContentUnits)
    end
  end
end
