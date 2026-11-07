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
      @rpm = katello_rpms(:one)
      ::Katello::RepositoryRpm.find_or_create_by!(:repository_id => library_repo.id, :rpm_id => @rpm.id)

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
      assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent, id: new_repo.id, force_index: false)
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
        cv_version = katello_content_view_versions(:library_view_version_2)
        new_repo.update(content_view_version_id: cv_version.id, relative_path: "blah")
        new_repo.update(version_href: "/test/versions/1/")
        library_repo.update(version_href: "/library_test/versions/1/", publication_href: "/library_test/publications/1/")
        new_repo.save!
        ::Katello::RepositoryRpm.find_or_create_by!(:repository_id => library_repo.id, :rpm_id => old_rpm.id)
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
                                  { :debs => [], :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
        assert_action_planned_with(action, ::Actions::Pulp3::Repository::CopyVersion, library_repo, SmartProxy.pulp_primary, new_repo)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate, new_repo)
        assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent, id: new_repo.id, force_index: false)
      end

      it 'generates the publication when the selected content is in the repository' do
        pulp3_cvv_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        rpm = old_rpm
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [rpm.id]})

        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate, new_repo)
        assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent, id: new_repo.id, force_index: false)
      end

      it 'indexes an adopted repository from the source it adopted' do
        pulp3_cvv_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.
          stubs(:adoptable_library_repos).returns(library_repo.root_id => library_repo)

        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyVersion)
        refute_action_planned(action, ::Actions::Pulp3::Repository::MultiCopyUnits)
        assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent,
                                   id: new_repo.id, force_index: true, source_repository_id: library_repo.id)
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

      it 'plans metadata for the clone when the multicopy block is skipped' do
        pulp3_cvv_setup
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_repo_mapping).returns({})

        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        refute_action_planned(action, ::Actions::Pulp3::Repository::MultiCopyUnits)
        refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate) do |repo, _options|
          repo == new_repo
        end
        assert_action_planned_with(action, ::Actions::Katello::Repository::IndexContent) do |plan_input|
          plan_input.first[:id] == new_repo.id
        end
      end

      it 'copies for changed roots and reuses untouched ones when dependency solving is on' do
        SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
        ::Katello::Repository.any_instance.stubs(:soft_copy_of_library?).returns(true)
        content_view_version.repositories.where(version_href: nil).update(version_href: 'not-nil-href/1/')
        stub_remote_user

        changed_library = katello_repositories(:rhel_6_x86_64)
        untouched_library = katello_repositories(:fedora_17_x86_64)
        [changed_library, untouched_library].each do |repo|
          repo.update!(:version_href => "/library_test/versions/#{repo.id}/",
                       :publication_href => "/library_test/publications/#{repo.id}/")
        end
        katello_repositories(:rhel_6_x86_64_dev_archive).update!(:version_href => '/archive/versions/1/')
        katello_repositories(:fedora_17_x86_64_library_view_2).update!(:version_href => '/archive/versions/2/')

        selected = ::Katello::Rpm.create!(:name => 'iu-selected', :pulp_id => 'iu-selected', :version => '1',
                                          :release => '1', :arch => 'x86_64', :filename => 'iu-selected-1-1.x86_64.rpm',
                                          :nvra => 'iu-selected-1-1.x86_64')
        ::Katello::RepositoryRpm.create!(:repository_id => changed_library.id, :rpm_id => selected.id)

        changed_dest = ::Katello::Repository.new(:pulp_id => 'iu-changed-dest', :library_instance_id => changed_library.id,
                                                 :root => changed_library.root)
        untouched_dest = ::Katello::Repository.new(:pulp_id => 'iu-untouched-dest', :library_instance_id => untouched_library.id,
                                                   :root => untouched_library.root)
        [changed_dest, untouched_dest].each do |repo|
          repo.update!(:content_view_version_id => content_view_version.id, :version_href => "/dest/#{repo.pulp_id}/versions/1/",
                       :relative_path => repo.pulp_id)
        end

        repository_mapping = { [changed_library] => changed_dest, [untouched_library] => untouched_dest }
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
        task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
        action.stubs(:task).returns(task)
        action.expects(:action_subject).with(content_view_version.content_view)

        plan_action(action, content_view_version, [library], :resolve_dependencies => true,
                                                                  :content => {:package_ids => [selected.id]})

        assert_action_planned_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits) do |repo_map, _unit_map, options|
          repo_map.keys.sort_by(&:to_s) == [[changed_library.id], [untouched_library.id]].sort_by(&:to_s) &&
            options[:dependency_solving]
        end
        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate) do |repo, options|
          repo == untouched_dest && options.is_a?(Hash) && options[:reuse_version] &&
            options[:source_repository] == untouched_library
        end
        assert_action_planned_with(action, ::Actions::Katello::Repository::MetadataGenerate) do |repo, options|
          repo == changed_dest && (options.nil? || !options[:reuse_version])
        end
      end
    end
  end
end
