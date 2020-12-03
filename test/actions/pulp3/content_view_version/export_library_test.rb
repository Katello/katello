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
      repo_ids_in_library = organization.default_content_view_version.repositories.yum_type.pluck(:id)

      plan_action(action, organization, destination_server: destination_server)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Publish) do |content_view, _|
        assert_equal content_view.name, "Export-Library-#{destination_server}"
        assert_equal content_view.repository_ids.sort, repo_ids_in_library.sort
      end

      assert_action_planned_with(action, ::Actions::Pulp3::Orchestration::ContentViewVersion::Export) do |**options|
        assert_equal version, options[:content_view_version]
        assert_equal destination_server, options[:destination_server]
      end
    end
  end
end
