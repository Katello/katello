require 'katello_test_helper'

module ::Actions::Pulp3::ContentView
  class DeleteRepositoryReferenceTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file_archive)
      @content_view = @repo.content_view
      ensure_creatable(@repo, @primary)
    end

    def test_create
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Create, @repo, @primary)
      repo_reference = Katello::Pulp3::RepositoryReference.find_by(:content_view => @content_view, :root_repository_id => @repo.root_id)
      assert repo_reference
      assert Katello::Pulp3::Api::File.new(@primary).repositories_api.read(repo_reference.repository_href)

      ForemanTasks.sync_task(::Actions::Pulp3::ContentView::DeleteRepositoryReferences, @content_view, @primary)
      refute Katello::Pulp3::RepositoryReference.find_by(:id => repo_reference.id)

      assert_raises(PulpFileClient::ApiError) do
        Katello::Pulp3::Api::File.new(@primary).repositories_api.read(repo_reference.repository_href)
      end
    end
  end
end
