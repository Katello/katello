require 'katello_test_helper'

module ::Actions::Pulp::Repository
  class ClearRepoTest < ::ActiveSupport::TestCase
    include VCR::TestCase

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @repo = katello_repositories(:pulp3_file_1)
      Katello::RepositorySupport.create_and_sync_repo(@repo)
    end

    def teardown
      Katello::RepositorySupport.destroy_repo(@repo)
    end

    def test_clear_repo
      @repo.index_content
      assert_equal @repo.files.count, 3

      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Clear, @repo, @master)
      @repo.index_content
      assert_equal @repo.files.count, 0
    ensure
      teardown
    end
  end
end
