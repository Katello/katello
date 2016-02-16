require 'katello_test_helper'

module ::Actions::Katello::ContentViewVersion
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

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
      stub_remote_user
      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_repository).returns(new_repo)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)
      plan_action(action, content_view_version, [library], :content => {:package_ids => ['foobar']})
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyRpm,
                                :source_pulp_id => library_repo.pulp_id,
                                :target_pulp_id => new_repo.pulp_id,
                                :full_clauses => { :filters => {:association => {'unit_id' => {'$in' => ['foobar']}}}},
                                :override_config => {:resolve_dependencies => false}, :include_result => true)
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

    let(:library_repo) do
      katello_repositories(:fedora_17_x86_64_library_view_2)
    end

    it 'plans' do
      stub_remote_user

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      plan_action(action, content_view_version, false, nil, 0)
      # verify everything bubbles through to the export action as we expect
      assert_action_planed_with(action, ::Actions::Katello::Repository::Export, [library_repo],
                                false, nil, 0, "-published_library_view-v2.0")
    end
  end
end
