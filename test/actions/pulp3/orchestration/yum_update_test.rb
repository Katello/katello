require 'katello_test_helper'

module ::Actions::Pulp3
  class YumUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      create_repo(@repo, @primary)

      @repo.root.update(
        verify_ssl_on_sync: false,
        mirroring_policy: ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE,
        ssl_ca_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_cert: katello_gpg_keys(:unassigned_gpg_key),
        ssl_client_key: katello_gpg_keys(:unassigned_gpg_key))

      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)
      assert_equal 1,
           Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count,
           "Expected a distribution reference."
    end

    def test_update_http_proxy_with_no_url
      @repo.root.update(url: nil)
      @repo.root.update(http_proxy_policy: ::Katello::RootRepository::USE_SELECTED_HTTP_PROXY)
      @repo.root.update(http_proxy_id: ::HttpProxy.find_by(name: 'myhttpproxy').id)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)
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

    def test_update_policy
      @repo.root.update(
        download_policy: 'on_demand')

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      yum_remote = ::Katello::Pulp3::Api::Yum.new(@primary).remotes_api
      assert_equal yum_remote.list.results.find { |remote| remote.name == "2_duplicate" }.policy, "on_demand"
    end

    def test_update_unset_unprotected
      @repo.root.update(unprotected: true)
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

  class YumUpdateNoUrlTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      ensure_creatable(@repo, @primary)

      @repo.root.update(url: nil)
      create_repo(@repo, @primary)
    end

    def test_addurl
      ::Katello::Pulp3::Repository.any_instance.stubs(:fail_missing_publication).returns(nil)
      @repo.root.update(url: "http://someotherurl")
      task = ForemanTasks.sync_task(
              ::Actions::Pulp3::Orchestration::Repository::Update,
              @repo,
              @primary)
      assert 'success', task.result
    end
  end
end
