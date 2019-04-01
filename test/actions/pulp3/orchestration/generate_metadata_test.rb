require 'katello_test_helper'

module ::Actions::Pulp3
  class GenerateMetadataTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file)
      @repo.root.update_attributes(:url => 'http://test/test/')
      create_repo(@repo, @master)
    end

    def test_generate_metadata
      refute @repo.version_href

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @repo, @master, repository_creation: true)
      @repo.reload

      assert @repo.version_href
      assert @repo.publication_href
    end
  end
end
