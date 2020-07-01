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

      assert_tree_planned_with(tree, Actions::Pulp::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions)
    end

    it 'plans proxy orphans cleanup with pulp3 mirror' do
      smart_proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)
      tree = plan_action_tree(action_class, smart_proxy)

      assert_tree_planned_with(tree, Actions::Pulp::OrphanCleanup::RemoveUnneededRepos)
      assert_tree_planned_with(tree, Actions::Pulp::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::RemoveOrphans)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanDistributions)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRemotes)
      assert_tree_planned_with(tree, Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions)
    end

    it 'runs and removes orphan content units' do
      smart_proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy)
      file_unit_orphan = Katello::FileUnit.new(:name => "file_unit", :pulp_id => "orphaned")
      file_unit_orphan.save!
      docker_unit_orphan = Katello::DockerTag.new(:name => "docker_unit", :pulp_id => "orphaned_docker")
      docker_unit_orphan.save!
      action = create_action(action_class)
      action.expects(:plan_self)
      plan_action action, smart_proxy
      run_action action
      assert_raises(ActiveRecord::RecordNotFound) { file_unit_orphan.reload }
      assert_raises(ActiveRecord::RecordNotFound) { docker_unit_orphan.reload }
    end
  end

  class RemoveUnneededReposTest < TestBase
    let(:action_class) { ::Actions::Pulp::OrphanCleanup::RemoveUnneededRepos }

    it "plans removal of unneeded repos with" do
      smart_proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)

      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([])
      action = create_action(action_class)
      action.expects(:plan_self)
      plan_action(action, smart_proxy)
    end
  end

  class RemoveOrphansTest < TestBase
    let(:action_class) { ::Actions::Pulp::Orchestration::OrphanCleanup::RemoveOrphans }
    it "Calls remove uneeded repos" do
      smart_proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)

      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([])
      action = create_action(action_class)
      plan_action(action, smart_proxy)
      assert_action_planed(action, ::Actions::Pulp::OrphanCleanup::RemoveUnneededRepos)
      assert_action_planed(action, ::Actions::Pulp::OrphanCleanup::RemoveOrphans)
    end
  end
end
