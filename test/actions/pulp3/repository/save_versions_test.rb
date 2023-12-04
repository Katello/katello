require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class SaveVersionsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
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
        returns(::PulpFileClient::FileFileRepositoryResponse.new(latest_version_href: "test_repo_1/2/"))
      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_2/").
        returns(::PulpFileClient::FileFileRepositoryResponse.new(latest_version_href: "test_repo_2/3/"))
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
        returns(::PulpFileClient::FileFileRepositoryResponse.new(latest_version_href: "test_repo_1/2/"))
      ::PulpFileClient::RepositoriesFileApi.any_instance.expects(:read).with("test_repo_2/").
        returns(::PulpFileClient::FileFileRepositoryResponse.new(latest_version_href: "test_repo_2/3/"))
      ::Katello::Repository.any_instance.stubs(:index_content).returns(true)

      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersions, repos, tasks: tasks_map)

      @repo1.reload
      @repo2.reload

      assert_equal @repo1.version_href, "test_repo_1/2/"
      assert_equal @repo2.version_href, "test_repo_2/3/"
      assert_equal task.output[:contents_changed], true
      assert_empty task.output[:updated_repositories] - [@repo1.id, @repo2.id]
    end

    def test_save_version_with_outdated_publication
      @repo1.update(version_href: "test_repo_1/1/", publication_href: "test_publ_1/")
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_1/", root_repository_id: @repo1.root_id, content_view_id: @repo1.content_view.id).save

      tasks_map = [{ created_resources: [] }]

      ::PulpFileClient::PublicationsFileApi.any_instance.expects(:read).with("test_publ_1/").
        returns(::PulpFileClient::FileFilePublicationResponse.new(repository_version: "test_repo_1/0/"))
      ::Katello::Repository.any_instance.stubs(:index_content).returns(true)

      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::SaveVersion, @repo1, tasks: tasks_map)

      @repo1.reload

      assert_equal "test_repo_1/1/", @repo1.version_href
      assert task.output[:contents_changed]
      assert_nil task.output[:updated_repositories]
    end
  end
end
