require 'katello_test_helper'

class FileDeleteTest < ActiveSupport::TestCase
  include ::Katello::Pulp3Support

  def setup
    @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
    @repo = katello_repositories(:generic_file)
    @repo.root.update_attributes(:url => 'http://test/test/')
    ensure_creatable(@repo, @master)
    ForemanTasks.sync_task(
      ::Actions::Pulp3::Orchestration::Repository::Create, @repo, @master)
  end

  def test_delete
    ForemanTasks.sync_task(
      ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
    @repo.reload

    repo_reference = Katello::Pulp3::RepositoryReference.find_by(
      :root_repository_id => @repo.root.id,
      :content_view_id => @repo.content_view.id)

    assert_nil repo_reference
  end
end
