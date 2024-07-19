require 'katello_test_helper'

module ::Actions::Katello::Environment
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }

    before do
      set_user
    end
  end

  class PublishContainerRepositoriesTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::PublishContainerRepositories }
    let(:action) { create_action action_class }

    let(:environment) { stub }

    it 'does not plan for container push library repos' do
      container_push_repo = ::Katello::RootRepository.find_by(name: 'busybox').library_instance
      container_push_repo.root.update_column(:is_container_push, true)
      environment.stubs(:repositories).returns(::Katello::Repository.where(id: container_push_repo.id))
      container_push_repo.expects(:set_container_repository_name).never
      container_push_repo.expects(:clear_smart_proxy_sync_histories).never
      action.stubs(:action_subject).with(environment)

      plan_action(action, environment)
      refute_action_planned(action, ::Actions::Katello::Repository::InstanceUpdate)
      refute_action_planned(action, ::Actions::Katello::Repository::CapsuleSync)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::Destroy }
    let(:action) { create_action action_class }

    let(:environment) { stub }

    it 'plans' do
      stub_remote_user
      content_view = stub
      cve = mock(:content_view => content_view)
      action.stubs(:action_subject).with(environment)
      environment.expects(:content_view_environments).returns([cve])
      environment.expects(:deletable?).returns(true)
      plan_action(action, environment)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Remove, content_view, :content_view_environments => [cve], :skip_repo_destroy => false, :organization_destroy => false)
    end
  end

  class DestroyWithOrganizationDestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::Destroy }
    let(:action) { create_action action_class }

    let(:environment) { stub }

    it 'plans' do
      stub_remote_user
      content_view = stub
      cve = mock(:content_view => content_view)
      action.stubs(:action_subject).with(environment)
      environment.expects(:content_view_environments).returns([cve])
      environment.expects(:deletable?).returns(true)
      environment.expects(:hostgroups).returns(::Hostgroup.none)
      environment.expects(:hosts).returns(::Host.none)
      environment.expects(:hosts=).never
      plan_action(action, environment, :organization_destroy => true)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Remove, content_view, :content_view_environments => [cve], :skip_repo_destroy => false, :organization_destroy => true)
    end
  end
end
