require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RefreshReposTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::CapsuleSupport

    def setup
      set_user
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      @smart_proxy = capsule_content.smart_proxy
      capsule_content.smart_proxy.add_lifecycle_environment(katello_environments(:library))
      SmartProxy.any_instance.stubs(:pulp_primary?).returns(false)
    end

    describe 'Refresh Repos pulp2' do
      let(:action_class) { ::Actions::Pulp::Orchestration::Repository::RefreshRepos }

      it 'create' do
        repo = katello_repositories(:fedora_17_x86_64)
        pulp_repo = repo.backend_service(@smart_proxy)
        ::Katello::Repository.any_instance.expects(:backend_service).with(@smart_proxy).returns(pulp_repo)

        planned_action = create_and_plan_action action_class, @smart_proxy, repository: repo
        # no repos in the capsule
        ::Katello::Pulp::SmartProxyRepository.any_instance.expects(:current_repositories).returns([])

        # but 1 repo is available to the capsule, so make sure it gets created
        pulp_repo.expects(:create_mirror_entities).once
        run_action planned_action
      end

      it 'updates' do
        repo = katello_repositories(:fedora_17_x86_64)
        pulp_repo = repo.backend_service(@smart_proxy)
        ::Katello::Repository.any_instance.expects(:backend_service).with(@smart_proxy).returns(pulp_repo)

        planned_action = create_and_plan_action action_class, @smart_proxy, repository: repo
        # repo already exist in capsule
        ::Katello::Pulp::SmartProxyRepository.any_instance.expects(:current_repositories).returns([repo])
        pulp_repo.expects(:refresh_mirror_entities).once.returns([])
        run_action planned_action
      end
    end

    describe 'Refresh Repos pulp3' do
      let(:action_class) { ::Actions::Pulp3::Orchestration::Repository::RefreshRepos }

      it 'creates' do
        with_pulp3_features(@smart_proxy)
        repo = katello_repositories(:pulp3_file_1)
        pulp_repo = repo.backend_service(@smart_proxy)
        ::Katello::Repository.any_instance.expects(:backend_service).with(@smart_proxy).returns(pulp_repo)

        planned_action = create_and_plan_action action_class, @smart_proxy, repository: repo
        # no repos in the capsule
        ::Katello::Pulp3::SmartProxyRepository.any_instance.expects(:current_repositories).returns([])

        # but 1 repo is available to the capsule, so make sure it gets created
        pulp_repo.expects(:create_mirror_entities).once
        run_action planned_action
      end

      it 'updates' do
        with_pulp3_features(@smart_proxy)
        repo = katello_repositories(:pulp3_file_1)
        pulp_repo = repo.backend_service(@smart_proxy)
        ::Katello::Repository.any_instance.expects(:backend_service).with(@smart_proxy).returns(pulp_repo)

        planned_action = create_and_plan_action action_class, @smart_proxy, repository: repo
        # repo already exist in capsule
        ::Katello::Pulp3::SmartProxyRepository.any_instance.expects(:current_repositories).returns([repo])
        pulp_repo.expects(:refresh_mirror_entities).once.returns([])
        run_action planned_action
      end
    end
  end
end
