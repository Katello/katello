require 'katello_test_helper'

module ::Actions::Pulp3::ContentView
  class ExportRepositoryTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::Actions::RemoteAction

    let(:action_class) do
      ::Actions::Pulp3::Orchestration::ContentViewVersion::ExportRepository
    end

    let(:action) do
      create_action action_class
    end

    let(:version) do
      katello_content_view_versions(:library_view_version_1)
    end

    let(:repository) do
      version.organization.default_content_view_version.repositories.yum_type.immediate.first
    end

    it 'should plan properly' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:version).returns(version)
      action_class.any_instance.expects(:action_subject).with(repository)

      plan_action(action, repository)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Publish) do |*args|
        content_view = args.first
        assert_equal content_view.name, "Export-#{repository.label}-#{repository.id}"
        assert_equal content_view.repository_ids.sort, [repository.id]
        assert content_view.generated_for_repository?
      end

      assert_action_planned_with(action, Actions::Katello::ContentViewVersion::Export) do |_, **options|
        assert_equal version, options[:content_view_version]
      end
    end

    it 'should fail on lazy repositories' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:version).returns(version)
      repo = version.organization.default_content_view_version.repositories.yum_type.non_immediate.first
      action_class.any_instance.expects(:action_subject).with(repo)

      exception = assert_raises(RuntimeError) do
        plan_action(action, repo)
      end
      assert_match(/NOTE: Unable to fully export repository '#{repo}' /, exception.message)
    end
  end
end
