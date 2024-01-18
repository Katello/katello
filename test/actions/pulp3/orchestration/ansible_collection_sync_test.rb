require 'katello_test_helper'

module ::Actions::Pulp3
  class AnsibleCollectionSyncTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_ansible_collection_1)
      @repo.root.update(:ansible_collection_auth_url => nil, :ansible_collection_auth_token => nil)
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)

      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert repository_reference
      refute_empty repository_reference.repository_href
      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)
      @repo_version_href = @repo.version_href
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_sync
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      refute_equal @repo.version_href, @repo_version_href
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
    end

    def test_sync_mirror_false
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
      @repo.index_content
      pre_content = ::Katello::RepositoryAnsibleCollection.where(:repository_id => @repo.id)
      pre_content_count = pre_content.count
      @repo.root.update(:ansible_collection_requirements => "---\n
  collections:\n
  - newswangerd.collection_demo", :mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE)
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Update,
          @repo,
          @primary)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      post_content = ::Katello::RepositoryAnsibleCollection.where(:repository_id => @repo.id)
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href
      assert_operator pre_content_count, :<, post_content.count
      assert_empty pre_content - post_content
    end

    def test_sync_mirror_true
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      pre_content = ::Katello::RepositoryAnsibleCollection.where(:repository_id => @repo.id)
      @repo.root.update(:ansible_collection_requirements => "---\n
  collections:\n
  - newswangerd.collection_demo")

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Update,
          @repo,
          @primary)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content

      post_content = ::Katello::AnsibleCollection.in_repositories(@repo)
      assert_equal pre_content - post_content, pre_content

      refute_nil post_content.first.description
      refute_empty post_content.first.tags
    end
  end
end
