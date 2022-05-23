require 'katello_test_helper'

module ::Actions::Pulp3
  class AptUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:debian_10_amd64_duplicate)
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

    def test_update_http_proxy_with_no_url
      @repo.root.update(url: nil)
      @repo.root.update(http_proxy_policy: ::Katello::RootRepository::USE_SELECTED_HTTP_PROXY)
      @repo.root.update(http_proxy_id: ::HttpProxy.find_by(name: 'myhttpproxy').id)

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

      yum_remote = ::Katello::Pulp3::Api::Apt.new(@primary).remotes_api
      assert_equal yum_remote.list.results.find { |remote| remote.name == "Debian_10_duplicate" }.policy, "on_demand"
    end
  end

  class AptUpdateNoUrlTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:debian_10_amd64_duplicate)
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
