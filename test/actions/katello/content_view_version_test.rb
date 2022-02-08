require 'katello_test_helper'

module ::Actions::Katello::ContentViewVersion
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryBot::Syntax::Methods

    before do
      set_user
    end
  end

  class IncrementalUpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewVersion::IncrementalUpdate }
    let(:action) { create_action action_class }

    let(:library) do
      katello_environments(:library)
    end

    let(:content_view_version) do
      katello_content_view_versions(:library_view_version_2)
    end

    let(:library_repo) do
      katello_repositories(:fedora_17_x86_64)
    end

    it 'plans' do
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(false)
      stub_remote_user
      @rpm = library_repo.rpms.first

      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
      repository_mapping = {}
      repository_mapping[[library_repo]] = new_repo
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)
      plan_action(action, content_view_version, [library], :content => {:package_ids => [@rpm.id]})

      assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate, new_repo)
      assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent, id: new_repo.id)
    end

    describe 'pulp3' do
      let(:old_rpm) do
        katello_rpms(:one)
      end

      let(:new_repo) do
        ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
      end

      let(:library_repo) do
        katello_repositories(:rhel_7_x86_64)
      end

      def pulp3_cvv_setup
        SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
        content_view_version.repositories.where(version_href: nil).update(version_href: 'not-nil-href/1/')
        stub_remote_user

        repository_mapping = {}
        new_repo.update(content_view_version_id: ::Katello::ContentViewVersion.first.id, relative_path: "blah")
        new_repo.update(version_href: "/test/versions/1/")
        library_repo.update(version_href: "/library_test/versions/1/")
        new_repo.save!
        repository_mapping[[library_repo]] = new_repo
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
        task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
        action.stubs(:task).returns(task)
        action.expects(:action_subject).with(content_view_version.content_view)
      end

      it 'respects dep solving false' do
        pulp3_cvv_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = {}
        pulp3_repo_map[[library_repo.id]] = { :dest_repo => new_repo.id, :base_version => nil }
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::CopyContent, library_repo, SmartProxy.pulp_primary, new_repo, copy_all: true, remove_all: true)
        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate, new_repo)
        assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent, id: new_repo.id)
      end

      it 'respects dep solving true' do
        pulp3_cvv_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(false)
        plan_action(action, content_view_version, [library], :resolve_dependencies => true, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = {}
        pulp3_repo_map[[library_repo.id]] = { :dest_repo => new_repo.id, :base_version => 1 }
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => true)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
      end
    end
  end
end
