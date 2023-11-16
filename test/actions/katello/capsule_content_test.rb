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
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:list).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:create).returns(nil)
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::Sync }
    let(:staging_environment) { katello_environments(:staging) }
    let(:dev_environment) { katello_environments(:dev) }

    before do
      SmartProxy.any_instance.stubs(:pulp_primary?).returns(false)
    end

    it 'plans correctly for a pulp3 file repo' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:pulp3_file_1)
      repo.root.update_attribute(:unprotected, true)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
                }
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::Sync) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::GenerateMetadata) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end
    end

    it 'plans correctly for a pulp3 yum repo without the proper plugin' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      capsule_content.smart_proxy.stubs(:capabilities).returns([])
      repo = katello_repositories(:fedora_17_x86_64)
      repo.root.update_attribute(:unprotected, true)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      refute_tree_planned(tree, ::Actions::Pulp3::CapsuleContent::Sync)
    end

    it 'plans correctly for a pulp3 yum repo' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:fedora_17_x86_64)
      repo.root.update_attribute(:unprotected, true)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
      }
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::Sync) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::GenerateMetadata) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end
    end

    it 'plans correctly for a pulp3 docker repo' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:pulp3_docker_1)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::Sync) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end
    end

    it 'plans correctly for a pulp3 ansible collection repo' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      repo = katello_repositories(:pulp3_ansible_collection_1)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end
    end

    it 'plans correctly for a pulp3 apt repo' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:pulp3_deb_1)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::Sync) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::GenerateMetadata) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end

      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        assert_equal repo.id, input[:repository_id]
      end
    end

    it 'plans correctly for a pulp2 apt repo' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(false)
      repo = katello_repositories(:debian_9_amd64)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
    end

    it 'plans correctly for a pulp yum repo' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      capsule_content.smart_proxy.features = capsule_content.smart_proxy.features - [Feature.name_map[SmartProxy::PULP3_FEATURE]]
      repo = katello_repositories(:fedora_17_x86_64)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
    end

    it 'plans correctly for a pulp2 file repo' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:generic_file)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  repository_ids_list: nil,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
    end

    it 'allows limiting scope of the syncing to one environment' do
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(dev_environment)
      repos_in_dev = Katello::Repository.in_environment(dev_environment).pluck(:pulp_id)

      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :environment_id => dev_environment.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: nil,
                  repository_ids_list: nil,
                  environment_id: dev_environment.id
                }
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::Sync) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        repo = Katello::Repository.find(input[:repository_id])
        assert_includes repos_in_dev, repo.pulp_id
      end

      assert_tree_planned_with(tree, ::Actions::Pulp3::CapsuleContent::GenerateMetadata) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        repo = Katello::Repository.find(input[:repository_id])
        assert_includes repos_in_dev, repo.pulp_id
      end

      assert_tree_planned_with(tree, Actions::Pulp3::CapsuleContent::RefreshDistribution) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:smart_proxy_id]
        repo = Katello::Repository.find(input[:repository_id])
        assert_includes repos_in_dev, repo.pulp_id
        repos_in_dev.delete(repo.pulp_id)
      end

      assert_empty repos_in_dev
    end

    it 'fails when trying to sync to the default capsule' do
      proxy = SmartProxy.pulp_primary
      proxy.stubs(:pulp_primary?).returns(true)
      action = create_action(action_class)
      action.expects(:action_subject).with(proxy)
      assert_raises(RuntimeError) do
        plan_action(action, proxy)
      end
    end

    it 'fails when trying to sync a lifecyle environment that is not attached' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      action_class.any_instance.expects(:action_subject).with(capsule_content.smart_proxy)

      capsule_content.smart_proxy.lifecycle_environments = []
      action = plan_action_tree(action_class, capsule_content.smart_proxy, :environment_id => staging_environment.id)
      refute_empty action.errors
    end
  end
end
