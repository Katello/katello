require 'katello_test_helper'

module ::Actions::Pulp3
  class DockerUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:busybox)
      create_repo(@repo, @primary)

      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert_equal 1,
        Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count,
                   "Expected a distribution reference."
      @repo.root.update(
        verify_ssl_on_sync: false,
        ssl_ca_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_key: katello_gpg_keys(:unassigned_gpg_key))
    end

    def teardown
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
    end

    def test_update_ssl_validation
      refute @repo.root.verify_ssl_on_sync, "Respository verify_ssl_on_sync option was false."
      @repo.root.update(
        verify_ssl_on_sync: true)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
    end

    def test_update_url
      @repo.root.update(
        url: 'http://website.com/')

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
    end

    def test_update_upstream_name
      @repo.root.update(
        docker_upstream_name: 'test')

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
    end

    def test_update_limit_tags
      @repo.root.update!(
        include_tags: ['test_tag'], exclude_tags: ['other_tag'])

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
    end

    def test_update_limit_tags_empty
      @repo.root.update(
        include_tags: nil, exclude_tags: nil)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
    end

    def test_update_unset_unprotected
      assert @repo.root.unprotected
      assert_equal 1, Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count

      @repo.root.update(unprotected: false)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      dist_refs = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      assert_equal 1, dist_refs.count, "Expected 1 distribution reference."
    end

    def test_update_set_unprotected
      @repo.root.update(unprotected: false)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      dist_refs = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      assert_equal 1, dist_refs.count, "Expected only 1 distribution reference."
      @repo.root.update(unprotected: true)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      dist_refs = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)
      assert_equal 1, dist_refs.count, "Expected a distribution reference."
    end
  end
end
