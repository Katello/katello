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

      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersions, repos, tasks: tasks_map)

      @repo1.reload
      @repo2.reload

      assert_equal @repo1.version_href, "test_repo_1/2/"
      assert_equal @repo2.version_href, "test_repo_2/3/"
      assert_equal task.output[:contents_changed], true
      assert_empty task.output[:updated_repositories] - [@repo1.id, @repo2.id]
    end

    def test_save_new_version_from_lookup_with_nil_version_hrefs
      @repo1.update(version_href: nil)
      @repo2.update(version_href: nil)
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_1/", root_repository_id: @repo1.root_id, content_view_id: @repo1.content_view.id).save
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_2/", root_repository_id: @repo2.root_id, content_view_id: @repo2.content_view.id).save

      repos = [@repo1.id, @repo2.id]
      tasks_map = [{ created_resources: [] }]

      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_1/").
        returns(::PulpFileClient::FileFileRepository.new(latest_version_href: "test_repo_1/2/"))
      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_2/").
        returns(::PulpFileClient::FileFileRepository.new(latest_version_href: "test_repo_2/3/"))
      ::Katello::Repository.any_instance.stubs(:index_content).returns(true)

      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersions, repos, tasks: tasks_map)

      @repo1.reload
      @repo2.reload

      assert_equal @repo1.version_href, "test_repo_1/2/"
      assert_equal @repo2.version_href, "test_repo_2/3/"
      assert_equal task.output[:contents_changed], true
      assert_empty task.output[:updated_repositories] - [@repo1.id, @repo2.id]
    end

    def test_save_new_version_from_lookup
      @repo1.update(version_href: "test_repo_1/1/")
      @repo2.update(version_href: "test_repo_2/2/")
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_1/", root_repository_id: @repo1.root_id, content_view_id: @repo1.content_view.id).save
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_2/", root_repository_id: @repo2.root_id, content_view_id: @repo2.content_view.id).save

      repos = [@repo1.id, @repo2.id]
      tasks_map = [{ created_resources: [] }]

      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_1/").
        returns(::PulpFileClient::FileFileRepository.new(latest_version_href: "test_repo_1/2/"))
      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_2/").
        returns(::PulpFileClient::FileFileRepository.new(latest_version_href: "test_repo_2/3/"))
      ::Katello::Repository.any_instance.stubs(:index_content).returns(true)

      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersions, repos, tasks: tasks_map)

      @repo1.reload
      @repo2.reload

      assert_equal @repo1.version_href, "test_repo_1/2/"
      assert_equal @repo2.version_href, "test_repo_2/3/"
      assert_equal task.output[:contents_changed], true
      assert_empty task.output[:updated_repositories] - [@repo1.id, @repo2.id]
    end
  end
end
