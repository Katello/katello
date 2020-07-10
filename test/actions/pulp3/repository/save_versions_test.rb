require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class SaveVersionsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo1 = katello_repositories(:generic_file_archive)
      @repo2 = katello_repositories(:pulp3_file_1)
    end

    def test_save_new_version_in_map
      @repo1.update(version_href: "test_repo_1/1/")
      @repo2.update(version_href: "test_repo_2/2/")
      repos = [@repo1.id, @repo2.id]

      ::Katello::Repository.any_instance.stubs(:index_content).returns(nil)

      tasks_map = [{ created_resources: ["test_repo_1/2/", "test_repo_2/3/"] }]

      ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersions, repos, tasks: tasks_map)

      @repo1.reload
      @repo2.reload

      assert_equal @repo1.version_href, "test_repo_1/2/"
      assert_equal @repo2.version_href, "test_repo_2/3/"
    end
  end
end
