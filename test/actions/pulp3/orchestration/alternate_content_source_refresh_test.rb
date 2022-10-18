require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceRefreshTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @yum_acs.subpaths = ['rpm-zchunk/', 'rpm-with-modules/']
      @yum_acs.ssl_ca_cert_id = nil
      @yum_acs.ssl_client_cert_id = nil
      @yum_acs.ssl_client_key_id = nil
      @yum_acs.upstream_username = nil
      @yum_acs.upstream_password = nil
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @file_acs.subpaths = ['file/', 'file-many/', 'file-mixed/']
      @file_acs.ssl_ca_cert_id = nil
      @file_acs.ssl_client_cert_id = nil
      @file_acs.ssl_client_key_id = nil
      @file_acs.upstream_username = nil
      @file_acs.upstream_password = nil
      @yum_acs.save!
      @file_acs.save!
      @yum_simplified_acs = katello_alternate_content_sources(:yum_simplified_alternate_content_source)
      @file_simplified_acs = katello_alternate_content_sources(:file_simplified_alternate_content_source)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
    end

    def teardown
      @yum_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end

      @file_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end

      @yum_simplified_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end

      @file_simplified_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end
    end

    def test_yum_refresh
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
    end

    def test_yum_refresh_updates_remote
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      @yum_acs.update!(verify_ssl: false)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
      new_verify_ssl = smart_proxy_acs.backend_service.api.remotes_list(name: @yum_acs.name).first.tls_validation
      assert_equal new_verify_ssl, @yum_acs.verify_ssl
    end

    def test_yum_refresh_simplified
      ::Katello::Pulp3::Repository.any_instance.stubs(:generate_backend_object_name).returns(@yum_simplified_acs.name)
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_simplified_acs.name)
      repo = katello_repositories(:fedora_17_x86_64_duplicate)
      repo.root.update!(url: 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_simplified_acs.id, smart_proxy_id: @primary.id, repository_id: repo.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
    end

    def test_file_refresh_simplified
      ::Katello::Pulp3::Repository.any_instance.stubs(:generate_backend_object_name).returns(@file_simplified_acs.name)
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_simplified_acs.name)
      repo = katello_repositories(:pulp3_file_1)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_simplified_acs.id, smart_proxy_id: @primary.id, repository_id: repo.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
    end

    def test_file_refresh
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
    end
  end
end
