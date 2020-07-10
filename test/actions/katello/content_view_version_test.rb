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
      katello_repositories(:rhel_7_x86_64)
    end

    it 'plans' do
      SmartProxy.stubs(:pulp_master).returns(SmartProxy.find_by(name: "Unused Proxy"))
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(false)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_dest_base_version).returns(1)
      stub_remote_user
      @rpm = katello_rpms(:one)

      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
      repository_mapping = {}
      repository_mapping[[library_repo]] = new_repo
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)
      plan_action(action, content_view_version, [library], :content => {:package_ids => [@rpm.id]})

      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyUnits,
                                library_repo, new_repo,
                                Katello::Rpm.with_identifiers(@rpm.id),
                                :incremental_update => true)
    end

    it 'plans for pulp 3' do
      SmartProxy.stubs(:pulp_master).returns(SmartProxy.find_by(name: "Unused Proxy"))
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_dest_base_version).returns(1)
      stub_remote_user
      @rpm = katello_rpms(:one)

      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
      repository_mapping = {}
      new_repo.update(content_view_version_id: ::Katello::ContentViewVersion.first.id, relative_path: "blah")
      new_repo.save!
      repository_mapping[[library_repo]] = new_repo
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)
      plan_action(action, content_view_version, [library], :content => {:package_ids => [@rpm.id]})

      pulp3_repo_map = {}
      pulp3_repo_map[library_repo.id] = { :dest_repo => new_repo.id, :base_version => 1 }
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                pulp3_repo_map,
                                { :errata => [], :rpms => [@rpm.id] },
                                :dependency_solving => true)
    end
  end
  class ExportTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewVersion::Export }
    let(:action) { create_action action_class }

    let(:library) do
      katello_environments(:library)
    end

    let(:content_view_version) do
      katello_content_view_versions(:library_view_version_2)
    end

    let(:library_repos) do
      [katello_repositories(:rhel_6_x86_64_dev_archive), katello_repositories(:fedora_17_x86_64_library_view_2)]
    end

    let(:organization) { library.organization }

    it 'plans' do
      stub_remote_user

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      plan_action(action, content_view_version, false, nil, 0)
      # verify everything bubbles through to the export action as we expect
      assert_action_planed_with(action, ::Actions::Katello::Repository::Export) do |repos, export_to_iso, since, iso_size, group_id|
        assert_equal library_repos.sort, repos.sort
        refute export_to_iso
        assert_nil since
        assert_equal 0, iso_size
        assert_equal "#{organization.label}-published_library_view-v2.0", group_id
      end
    end

    it 'plans with date' do
      stub_remote_user

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      # the date should not be converted to an iso8601 when fed to Repository::Export.
      plan_action(action, content_view_version, false, '1841-01-01', 0)
      assert_action_planed_with(action, ::Actions::Katello::Repository::Export) do |repos, export_to_iso, since, iso_size, group_id|
        assert_equal library_repos.sort, repos.sort
        refute export_to_iso
        assert_equal '1841-01-01', since
        assert_equal 0, iso_size
        assert_equal "#{organization.label}-published_library_view-v2.0", group_id
      end
    end
  end
end
