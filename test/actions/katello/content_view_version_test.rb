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

    it 'outputs auto publish data' do
      cv = content_view_version.content_view
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(cv)
      repository_mapping = {}
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
      composites = [{id: 1}, {id: 2}, {id: 3}]
      Katello::ContentView.any_instance.expects(:auto_publish_composites).returns(composites)

      plan_action(action, content_view_version, [])
      run = run_action(action)

      assert_equal run.input[:new_content_view_version_id], run.output[:auto_publish_content_view_version_id]
      assert_equal [1, 2, 3], run.output[:auto_publish_content_view_ids]
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

      def pulp3_cvv_setup(extra_repository_mapping = {})
        SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
        content_view_version.repositories.where(version_href: nil).update(version_href: 'not-nil-href/1/')
        stub_remote_user

        repository_mapping = {}
        cv_version = katello_content_view_versions(:library_view_version_2)
        new_repo.update(content_view_version_id: cv_version.id, relative_path: "blah")
        new_repo.update(version_href: "/test/versions/1/")
        library_repo.update(version_href: "/library_test/versions/1/")
        new_repo.save!
        repository_mapping[[library_repo]] = new_repo
        repository_mapping.merge!(extra_repository_mapping)
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
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
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
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => true)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
      end

      # A second repo whose archived copy already matches its library instance, i.e. nothing is copied into it.
      def pulp3_unchanged_repo_setup
        unchanged_library_repo = katello_repositories(:rhel_6_x86_64)
        unchanged_old_repo = katello_repositories(:rhel_6_x86_64_dev_archive)
        unchanged_new_repo = ::Katello::Repository.new(:pulp_id => 388, :library_instance_id => unchanged_library_repo.id, :root => unchanged_library_repo.root)
        unchanged_new_repo.update!(content_view_version_id: katello_content_view_versions(:library_view_version_1).id, relative_path: "blah_unchanged")

        pulp3_cvv_setup([unchanged_library_repo] => unchanged_new_repo)
        unchanged_library_repo.update!(version_href: "/unchanged/versions/1/")
        unchanged_old_repo.update!(version_href: "/unchanged/versions/1/")
        [unchanged_library_repo, unchanged_old_repo, unchanged_new_repo]
      end

      def assert_cloned_to_version(sources, dest_repo)
        assert_action_planned_with(action, ::Actions::Katello::Repository::CloneToVersion,
                                   sources, action.new_content_view_version, dest_repo, incremental: true)
      end

      it 'only pre-copies, publishes and indexes repos that received content' do
        _unchanged_library_repo, _unchanged_old_repo, unchanged_new_repo = pulp3_unchanged_repo_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)

        action.expects(:copy_repos).with(new_repo).once
        action.expects(:copy_repos).with(unchanged_new_repo).never
        # The pre-copy is the only place that asks the destination repo whether it is a soft copy.
        unchanged_new_repo.expects(:soft_copy_of_library?).never
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = { [library_repo.id] => { :dest_repo => new_repo.id, :base_version => nil } }
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::CopyContent, library_repo, SmartProxy.pulp_primary, new_repo, copy_all: true, remove_all: true)
      end

      it 'still clones repos that receive no content' do
        unchanged_library_repo, _unchanged_old_repo, unchanged_new_repo = pulp3_unchanged_repo_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        action.stubs(:copy_repos)

        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        assert_cloned_to_version([library_repo], new_repo)
        assert_cloned_to_version([unchanged_library_repo], unchanged_new_repo)
      end

      it 'copies into a repo whose archived version differs from its library instance' do
        unchanged_library_repo, unchanged_old_repo, unchanged_new_repo = pulp3_unchanged_repo_setup
        unchanged_old_repo.update!(version_href: "/unchanged/versions/0/")
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)

        action.expects(:copy_repos).with(new_repo).once
        action.expects(:copy_repos).with(unchanged_new_repo).once
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = {
          [library_repo.id] => { :dest_repo => new_repo.id, :base_version => nil },
          [unchanged_library_repo.id] => { :dest_repo => unchanged_new_repo.id, :base_version => nil },
        }
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::CopyContent, library_repo, SmartProxy.pulp_primary, new_repo, copy_all: true, remove_all: true)
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::CopyContent, unchanged_library_repo, SmartProxy.pulp_primary, unchanged_new_repo, copy_all: true, remove_all: true)
      end

      it 'copies nothing when no repo received content' do
        unchanged_library_repo, _unchanged_old_repo, unchanged_new_repo = pulp3_unchanged_repo_setup
        old_library_repo_copy = content_view_version.repositories.archived.find_by(root_id: library_repo.root_id)
        old_library_repo_copy.update!(version_href: library_repo.reload.version_href)
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)

        action.expects(:copy_repos).never
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        refute_action_planned(action, ::Actions::Pulp3::Repository::MultiCopyUnits)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
        assert_cloned_to_version([library_repo], new_repo)
        assert_cloned_to_version([unchanged_library_repo], unchanged_new_repo)
      end

      it 'copies without a pre-copy into a changed repo that already has its own version, next to an unchanged repo' do
        _unchanged_library_repo, _unchanged_old_repo, unchanged_new_repo = pulp3_unchanged_repo_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(false)

        action.expects(:copy_repos).with(new_repo).once
        action.expects(:copy_repos).with(unchanged_new_repo).never
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = { [library_repo.id] => { :dest_repo => new_repo.id, :base_version => 1 } }
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
      end
    end
  end
end
