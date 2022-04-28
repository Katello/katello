require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceCreateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
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
      @yum_acs.reload

      @file_acs.smart_proxies.each do |proxy|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, @file_acs, proxy)
      end
      @file_acs.reload
    end

    def test_yum_create
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @yum_acs, @primary)
      assert_equal 1, @yum_acs.smart_proxy_alternate_content_sources.count
      assert @yum_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/rpm/rpm/')
      assert @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/rpm/rpm/')
    end

    def test_file_create
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @file_acs, @primary)
      assert_equal 1, @file_acs.smart_proxy_alternate_content_sources.count
      assert @file_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/file/file/')
      assert @file_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/file/file/')
    end

    def test_yum_create_complex
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ca = katello_gpg_keys(:fedora_ca)
      cert = katello_gpg_keys(:fedora_cert)
      key = katello_gpg_keys(:fedora_key)
      http_proxy = FactoryBot.create(:http_proxy)
      http_proxy.name = 'acs http proxy'
      http_proxy.url = 'http://acs-url-proxy.com'

      ca.save!
      cert.save!
      key.save!
      http_proxy.save!

      @yum_acs.ssl_ca_cert = ca
      @yum_acs.ssl_client_cert = cert
      @yum_acs.ssl_client_key = key
      @yum_acs.http_proxy = http_proxy
      @yum_acs.update(subpaths: ['test/', 'rpms/', 'manicotti/'])

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @yum_acs, @primary)
      assert_equal 1, @yum_acs.smart_proxy_alternate_content_sources.count
      assert @yum_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/rpm/rpm/')
      assert @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/rpm/rpm/')
    end
  end
end
