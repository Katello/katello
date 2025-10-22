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
    end

    def teardown
      @yum_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end
      @yum_acs.reload

      @file_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end
      @file_acs.reload
    end

    def test_yum_create
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      assert_equal 1, @yum_acs.smart_proxy_alternate_content_sources.count
      assert @yum_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/rpm/rpm/')
      assert @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/rpm/rpm/')
      assert_not_nil @yum_acs.smart_proxy_alternate_content_sources.first.remote_prn
      assert_match(/^prn:rpm\.rpmremote:[0-9a-f\-]+$/, @yum_acs.smart_proxy_alternate_content_sources.first.remote_prn)
      assert_not_nil @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn
      assert_match(/^prn:rpm\.rpmalternatecontentsource:[0-9a-f\-]+$/, @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn)
    end

    def test_file_create
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      assert_equal 1, @file_acs.smart_proxy_alternate_content_sources.count
      assert @file_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/file/file/')
      assert @file_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/file/file/')
      assert_not_nil @file_acs.smart_proxy_alternate_content_sources.first.remote_prn
      assert_match(/^prn:file\.fileremote:[0-9a-f\-]+$/, @file_acs.smart_proxy_alternate_content_sources.first.remote_prn)
      assert_not_nil @file_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn
      assert_match(/^prn:file\.filealternatecontentsource:[0-9a-f\-]+$/, @file_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn)
    end

    def test_yum_create_complex
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ca = katello_gpg_keys(:real_ca)
      cert = katello_gpg_keys(:real_cert)
      key = katello_gpg_keys(:real_key)
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
      @yum_acs.use_http_proxies = true
      @yum_acs.update(subpaths: ['test/', 'rpms/', 'manicotti/'])

      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      assert_equal 1, @yum_acs.smart_proxy_alternate_content_sources.count
      assert @yum_acs.smart_proxy_alternate_content_sources.first.remote_href.start_with?('/pulp/api/v3/remotes/rpm/rpm/')
      assert @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_href.start_with?('/pulp/api/v3/acs/rpm/rpm/')
      assert_not_nil @yum_acs.smart_proxy_alternate_content_sources.first.remote_prn
      assert_match(/^prn:rpm\.rpmremote:[0-9a-f\-]+$/, @yum_acs.smart_proxy_alternate_content_sources.first.remote_prn)
      assert_not_nil @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn
      assert_match(/^prn:rpm\.rpmalternatecontentsource:[0-9a-f\-]+$/, @yum_acs.smart_proxy_alternate_content_sources.first.alternate_content_source_prn)
    end
  end
end
