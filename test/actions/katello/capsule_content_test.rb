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
                  environment_id: nil
                }
      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
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
        refute input[:options][:use_repository_version]
        assert input[:options][:tasks].present?
      end
    end

    it 'plans correctly for a pulp3 yum repo' do
      with_pulp3_yum_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:fedora_17_x86_64)
      repo.root.update_attribute(:unprotected, true)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  environment_id: nil
      }
      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
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
        refute input[:options][:use_repository_version]
        assert input[:options][:tasks].present?
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
        assert input[:options][:use_repository_version]
        refute input[:options][:tasks].present?
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
        assert input[:options][:use_repository_version]
        refute input[:options][:tasks].present?
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
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
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
        refute input[:options][:use_repository_version]
        assert input[:options][:tasks].present?
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
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)

      assert_tree_planned_with(tree, Actions::Pulp::Consumer::SyncCapsule) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:capsule_id]
        assert_equal repo.pulp_id, input[:repo_pulp_id]
        assert input[:sync_options][:remove_missing]
      end
    end

    it 'plans correctly for a pulp yum repo' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      capsule_content.smart_proxy.features = capsule_content.smart_proxy.features - [Feature.name_map[SmartProxy::PULP3_FEATURE]]
      repo = katello_repositories(:fedora_17_x86_64)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_steps(tree, ::Actions::Pulp3::ContentGuard::Refresh)
      assert_tree_planned_with(tree, Actions::Pulp::Consumer::SyncCapsule) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:capsule_id]
        assert_equal repo.pulp_id, input[:repo_pulp_id]
        assert input[:sync_options][:remove_missing]
      end
    end

    it 'plans correctly for a pulp2 file repo' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:generic_file)
      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: repo.id,
                  environment_id: nil
                }

      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_with(tree, Actions::Pulp::Consumer::UnassociateUnits, capsule_id: capsule_content.smart_proxy.id, repo_pulp_id: repo.pulp_id)
      assert_tree_planned_with(tree, Actions::Pulp::Consumer::SyncCapsule) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:capsule_id]
        assert_equal repo.pulp_id, input[:repo_pulp_id]
        refute input[:sync_options][:remove_missing]
      end
    end

    it 'allows limiting scope of the syncing to one environment' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(dev_environment)
      repos_in_dev = Katello::Repository.in_environment(dev_environment).pluck(:pulp_id)
      cvpes_in_dev = Katello::ContentViewPuppetEnvironment.in_environment(dev_environment).pluck(:pulp_id)

      tree = plan_action_tree(action_class, capsule_content.smart_proxy, :environment_id => dev_environment.id)
      options = { smart_proxy_id: capsule_content.smart_proxy.id,
                  content_view_id: nil,
                  repository_id: nil,
                  environment_id: dev_environment.id
                }
      assert_tree_planned_with(tree, ::Actions::Pulp::Orchestration::Repository::RefreshRepos, options)
      assert_tree_planned_with(tree, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, options)

      assert_tree_planned_with(tree, Actions::Pulp::Consumer::UnassociateUnits) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:capsule_id]
        assert_includes repos_in_dev, input[:repo_pulp_id]
        repo = ::Katello::Repository.find_by(pulp_id: input[:repo_pulp_id])
        refute_includes ['yum', 'puppet'], repo.content_type
        refute capsule_content.smart_proxy.pulp3_support?(repo)
      end

      assert_tree_planned_with(tree, Actions::Pulp::Consumer::SyncCapsule) do |input|
        assert_equal capsule_content.smart_proxy.id, input[:capsule_id]
        assert_includes (repos_in_dev + cvpes_in_dev), input[:repo_pulp_id]
        if repos_in_dev.include?(input[:repo_pulp_id])
          repo = ::Katello::Repository.find_by(pulp_id: input[:repo_pulp_id])
          if ["deb", "yum", "puppet"].include?(repo.content_type)
            assert input[:sync_options][:remove_missing]
          else
            refute input[:sync_options][:remove_missing]
          end
          refute capsule_content.smart_proxy.pulp3_support?(repo)
          repos_in_dev.delete(input[:repo_pulp_id])
        else
          # test cvpe's
          assert input[:sync_options][:remove_missing]
          cvpes_in_dev.delete(input[:repo_pulp_id])
          cvpe = Katello::ContentViewPuppetEnvironment.find_by(pulp_id: input[:repo_pulp_id])
          refute capsule_content.smart_proxy.pulp3_support?(cvpe.nonpersisted_repository)
        end
      end

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
      assert_empty cvpes_in_dev
    end

    it 'fails when trying to sync to the default capsule' do
      SmartProxy.any_instance.stubs(:pulp_primary?).returns(true)
      action = create_action(action_class)
      action.expects(:action_subject).with(capsule_content.smart_proxy)
      assert_raises(RuntimeError) do
        plan_action(action, capsule_content.smart_proxy)
      end
    end

    it 'fails when trying to sync a lifecyle environment that is not attached' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      action_class.any_instance.expects(:action_subject).with(capsule_content.smart_proxy)

      capsule_content.smart_proxy.lifecycle_environments = []
      action = plan_action_tree(action_class, capsule_content.smart_proxy, :environment_id => staging_environment.id)
      refute_empty action.errors
    end

    it 'correctly generates a container gateway repository list' do
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      repo = katello_repositories(:pulp3_file_1)
      repo.root.update_attribute(:unprotected, true)

      repo_list_update_expectation = capsule_content.smart_proxy.expects(:update_container_repo_list).with do |arg|
        arg.include?({:repository => "busybox", :auth_required => true}) && arg.include?({:repository => "empty_organization-puppet_product-busybox", :auth_required => true})
      end
      repo_list_update_expectation.once.returns(true)

      repo_mapping_update_expectation = capsule_content.smart_proxy.expects(:update_user_container_repo_mapping).with do |arg|
        arg[:users].first["secret_admin"].include?({:repository => "empty_organization-puppet_product-busybox",
                                                    :auth_required => true}) &&
                                             arg[:users].first["secret_admin"].include?({:repository => "busybox",
                                                                                         :auth_required => true})
      end
      repo_mapping_update_expectation.once.returns(true)

      capsule_content.smart_proxy.expects(:container_gateway_users).returns(::User.where(login: 'secret_admin'))
      plan_action_tree(action_class, capsule_content.smart_proxy, :repository_id => repo.id)
    end
  end
end
