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
    end

    def synced_repos(action, repos)
      synced_repos = []
      repos.each do |_repo|
        assert_action_planed_with(action, ::Actions::Pulp::Consumer::SyncCapsule) do |(input)|
          synced_repos << input[:repo_pulp_id]
        end
      end
      synced_repos
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::Sync }
    let(:staging_environment) { katello_environments(:staging) }
    let(:dev_environment) { katello_environments(:dev) }
    let(:action) { create_action(action_class) }

    before do
      action.expects(:action_subject).with(capsule_content.smart_proxy)
    end

    it 'plans' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      action_class.any_instance.expects(:repos_needing_updates).returns([repository])
      capsule_content_sync = plan_action(action, capsule_content.smart_proxy)

      synced_repos = synced_repos(capsule_content_sync, capsule_content.repos_available_to_capsule)

      assert_equal synced_repos.sort.uniq, capsule_content.repos_available_to_capsule.map { |repo| repo.pulp_id }.sort.uniq
      assert_action_planed_with(action,
                                ::Actions::Pulp::Repository::Refresh,
                                repository,
                                :capsule_id => capsule_content.smart_proxy.id
                               )
    end

    it 'allows limiting scope of the syncing to one environment' do
      capsule_content.smart_proxy.add_lifecycle_environment(dev_environment)
      action_class.any_instance.expects(:repos_needing_updates).returns([])
      capsule_content_sync = plan_action(action, capsule_content.smart_proxy, :environment_id => dev_environment.id)
      synced_repos = synced_repos(capsule_content_sync, capsule_content.repos_available_to_capsule)

      assert_equal 9, synced_repos.uniq.count
    end

    it 'fails when trying to sync to the default capsule' do
      SmartProxy.any_instance.stubs(:pulp_master?).returns(true)
      assert_raises(RuntimeError) do
        plan_action(action, capsule_content.smart_proxy, :environment_id => dev_environment.id)
      end
    end

    it 'fails when trying to sync a lifecyle environment that is not attached' do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      Katello::Pulp::SmartProxyRepository.any_instance.stubs(:lifecycle_environments).returns([])
      assert_raises(RuntimeError) do
        plan_action(action, capsule_content.smart_proxy, :environment_id => staging_environment.id)
      end
    end
  end

  class CreateReposTest < TestBase
    include VCR::TestCase

    let(:action_class) { ::Actions::Katello::CapsuleContent::CreateRepos }

    let(:cert) do
      {
        :key => "this is a key",
        :cert => "this is a cert",
        :id => "123",
        :serial => {
          :id => 132,
          :revoked => false,
          :collected => false,
          :expiration => "2116-01-28t19:43:26.317+0000",
          :serial => 53,
          :created => "2016-01-28t19:43:26.770+0000",
          :updated => "2016-01-28T19:43:26.770+0000"
        },
        :created => "2016-01-28T19:43:26.780+0000",
        :updated => "2016-01-28T19:43:26.780+0000"
      }
    end

    before do
      capsule_content.smart_proxy.add_lifecycle_environment(environment)
      ::Cert::Certs.stubs(:ca_cert).returns(cert)
      ::Cert::Certs.stubs(:ueber_cert).with(repository.organization).returns(cert)
    end

    it 'creates repos needed on the capsule' do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:current_repositories).returns([custom_repository])
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:repos_available_to_capsule).returns([custom_repository, repository])

      action = create_and_plan_action(action_class, capsule_content.smart_proxy)

      assert_action_planed_with(action, ::Actions::Pulp::Repository::Create) do |input|
        input[0].must_equal(repository)
      end
    end
  end

  class RemoveUnneededReposTest < TestBase
    let(:action_class) { ::Actions::Katello::CapsuleContent::RemoveUnneededRepos }
    before do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:current_repositories).returns([custom_repository, repository])
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:repos_available_to_capsule).returns([custom_repository])
      ::Katello::Pulp::SmartProxyRepository.any_instance.expects(:delete_orphaned_repos).once.returns(nil)
    end

    it "removes unneeded repos" do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([])
      action = create_and_plan_action(action_class, capsule_content.smart_proxy)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::Destroy) do |(input)|
        input.must_equal(:repository_id => repository.id, :capsule_id => capsule_content.smart_proxy.id)
      end
    end

    it "removes deleted repos" do
      ::Katello::Pulp::SmartProxyRepository.any_instance.stubs(:orphaned_repos).returns([repository.pulp_id])
      action = create_and_plan_action(action_class, capsule_content.smart_proxy)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::Destroy) do |(input)|
        input.must_equal(:repository_id => repository.id, :capsule_id => capsule_content.smart_proxy.id)
      end
    end
  end
end
