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
      SmartProxy.stubs(:pulp_primary).returns(SmartProxy.find_by(name: "Unused Proxy"))
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(false)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_dest_base_version).returns(1)
      stub_remote_user
      @rpm = library_repo.rpms.first

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

    it 'does not plan CopyUnits if rpm not there in repo.' do
      SmartProxy.stubs(:pulp_primary).returns(SmartProxy.find_by(name: "Unused Proxy"))
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(false)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_dest_base_version).returns(1)
      stub_remote_user
      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
      repository_mapping = {}
      repository_mapping[[library_repo]] = new_repo
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)
      ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)

      # create a nonexistent rpm, and ask it to be incrementally copied over.
      # Copy Units should not happen in that case since this rpm is not any of the repos in the cvv.
      rpm = ::Katello::Rpm.create!(pulp_id: "I_dont_exist_really_in_a_repo")
      plan_action(action, content_view_version, [library], :content => {:package_ids => [rpm.id]})

      refute_action_planed action, ::Actions::Pulp::Repository::CopyUnits
    end

    it 'removes the correct puppet content during inc update' do
      clone = katello_repositories(:lib_p_forge)
      module1 = ::Katello::PuppetModule.create(
        :pulp_id => "pulp_id1",
        :name => "name1",
        :author => "author1",
        :version => "1.2.3"
      )
      module2 = ::Katello::PuppetModule.create(
        :pulp_id => "pulp_id2",
        :name => "name1",
        :author => "author1",
        :version => "2.2.3"
      )
      cvpe = ::Katello::ContentViewPuppetEnvironment.create(content_view_version_id: clone.content_view_version.id, pulp_id: "pulpidforcontentviewpuppetenviroment", name: "contentviewpuppetenvironment")
      ::Katello::ContentViewPuppetEnvironmentPuppetModule.create(puppet_module_id: module1.id, content_view_puppet_environment_id: cvpe.id)
      ::Katello::ContentViewPuppetEnvironmentPuppetModule.create(puppet_module_id: module2.id, content_view_puppet_environment_id: cvpe.id)

      action.expects(:remove_puppet_modules).with(clone, [module1.id, module2.id]).returns(true)
      mock_copy_puppet_module_output = "mock"
      mock_copy_puppet_module_output.stubs(:output).returns("output")
      action.stubs(:copy_puppet_module).returns(mock_copy_puppet_module_output)
      action.expects(:plan_action).with(::Actions::Pulp::ContentViewPuppetEnvironment::IndexContent, id: clone.id).returns(true)
      action.send(:copy_puppet_content, clone, [module2.id], clone.content_view_version)
    end

    it 'does not allow inc updating with multiple puppet modules of same name and author' do
      module1 = ::Katello::PuppetModule.create(
        :pulp_id => "pulp_id1",
        :name => "name1",
        :author => "author1",
        :version => "1.2.3"
      )
      module2 = ::Katello::PuppetModule.create(
        :pulp_id => "pulp_id2",
        :name => "name1",
        :author => "author1",
        :version => "2.2.3"
      )

      assert_raise RuntimeError, "Adding multiple versions of the same Puppet Module is not supported by incremental update.  The following Puppet Modules have duplicate versions in the incremental update content list: [\"name1-author1\"]" do
        action.send(:check_puppet_module_duplicates, [module1.id, module2.id])
      end
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
        SmartProxy.stubs(:pulp_primary).returns(SmartProxy.find_by(name: "Unused Proxy"))
        SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.stubs(:pulp3_dest_base_version).returns(1)
        stub_remote_user

        repository_mapping = {}
        new_repo.update(content_view_version_id: ::Katello::ContentViewVersion.first.id, relative_path: "blah")
        new_repo.update(version_href: "/test/versions/1/")
        library_repo.update(version_href: "/library_test/versions/1/")
        new_repo.save!
        repository_mapping[[library_repo]] = new_repo
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns(repository_mapping)
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)
        ::Actions::Katello::ContentViewVersion::IncrementalUpdate.any_instance.expects(:repos_to_copy).returns(repository_mapping.keys)
        task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
        action.stubs(:task).returns(task)
        action.expects(:action_subject).with(content_view_version.content_view)
      end

      it 'respects dep solving false' do
        pulp3_cvv_setup
        plan_action(action, content_view_version, [library], :resolve_dependencies => false, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = {}
        pulp3_repo_map[[library_repo.id]] = { :dest_repo => new_repo.id, :base_version => 1 }
        assert_action_planed_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => false)
      end

      it 'respects dep solving true' do
        pulp3_cvv_setup
        plan_action(action, content_view_version, [library], :resolve_dependencies => true, :content => {:package_ids => [old_rpm.id]})

        pulp3_repo_map = {}
        pulp3_repo_map[[library_repo.id]] = { :dest_repo => new_repo.id, :base_version => 1 }
        assert_action_planed_with(action, ::Actions::Pulp3::Repository::MultiCopyUnits,
                                  pulp3_repo_map,
                                  { :errata => [], :rpms => [old_rpm.id] },
                                  :dependency_solving => true)
      end
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
