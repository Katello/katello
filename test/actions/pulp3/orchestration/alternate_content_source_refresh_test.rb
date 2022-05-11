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
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
    end

    def teardown
      @yum_acs.smart_proxies.each do |proxy|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, @yum_acs, proxy)
      end

      @file_acs.smart_proxies.each do |proxy|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, @file_acs, proxy)
      end
    end

    def test_yum_refresh
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @yum_acs, @primary)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, @yum_acs, @primary)
    end

    def test_file_create
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @file_acs, @primary)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, @file_acs, @primary)
    end
  end
end
