require 'katello_test_helper'

module ::Actions::Pulp3::ContentView
  class ExportLibraryTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::Actions::RemoteAction

    let(:action_class) do
      ::Actions::Pulp3::Orchestration::ContentViewVersion::ExportLibrary
    end

    let(:action) do
      create_action action_class
    end

    let(:version) do
      katello_content_view_versions(:library_view_version_1)
    end

    let(:organization) do
      version.organization
    end

    let(:destination_server) do
      "example.com"
    end

    it 'should plan properly' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:version).returns(version)
      action_class.any_instance.expects(:action_subject).with(organization)
      immediate_repo_ids_in_library = organization.default_content_view_version.repositories.exportable.immediate_or_none.pluck(:id)

      plan_action(action, organization, destination_server: destination_server)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Publish) do |content_view, _|
        assert_equal content_view.name, "Export-Library-#{destination_server}"
        assert_equal content_view.repository_ids.sort, immediate_repo_ids_in_library.sort
        assert content_view.generated_for_library?
      end

      assert_action_planned_with(action, Actions::Katello::ContentViewVersion::Export) do |options, _|
        assert_equal version, options[:content_view_version]
        assert_equal destination_server, options[:destination_server]
      end
    end

    it 'should fail on lazy repositories on fail_on_missing_content' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:version).returns(version)
      refute_empty organization.default_content_view_version.repositories.yum_type.non_immediate
      action_class.any_instance.expects(:action_subject).with(organization)
      exception = assert_raises(RuntimeError) do
        plan_action(action, organization, destination_server: destination_server, fail_on_missing_content: true)
      end
      assert_match(/NOTE: Unable to fully export '#{organization.name}' /, exception.message)

      test_repo = organization.default_content_view_version.repositories.yum_type.non_immediate.first
      assert_match(/#{test_repo.name}/, exception.message)
    end
  end
end
