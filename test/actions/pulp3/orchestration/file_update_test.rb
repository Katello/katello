require 'katello_test_helper'

module ::Actions::Pulp3
  class FileUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:generic_file)
      @repo.root.update(:url => 'http://test/test/')
      create_repo(@repo, @primary)
      cert_path = "#{Katello::Engine.root}/test/fixtures/certs/content_guard.crt"
      cert = File.read(cert_path)
      Cert::Certs.stubs(:candlepin_client_ca_cert).returns(cert)

      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert_equal 1,
        Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count,
        "Expected a distribution reference."
      @repo.root.update(
        verify_ssl_on_sync: false,
        ssl_ca_cert: katello_gpg_keys(:real_ca),
        ssl_client_cert: katello_gpg_keys(:real_cert),
        ssl_client_key: katello_gpg_keys(:real_key))
    end

    def teardown
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
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

    def test_update_policy
      @repo.root.update(
        download_policy: 'on_demand')

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      file_remote = ::Katello::Pulp3::Api::File.new(@primary).remotes_api
      assert_equal file_remote.list.results.find { |remote| remote.name == "Default_Organization-Cabinet-My_Files" }.policy, "on_demand"
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
