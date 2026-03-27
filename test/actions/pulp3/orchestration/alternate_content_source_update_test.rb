require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    include Katello::Util::HttpProxy

    def setup
      @primary = SmartProxy.pulp_primary
      @repository = katello_repositories(:rhel_6_x86_64)
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @deb_acs = katello_alternate_content_sources(:deb_alternate_content_source)
      @simplified_acs = katello_alternate_content_sources(:yum_simplified_alternate_content_source)
      @simplified_acs.products << @repository.product
      @rhui_acs = katello_alternate_content_sources(:yum_alternate_content_source_rhui)
      @yum_acs.save!
      @file_acs.save!
      @deb_acs.save!
      @simplified_acs.save!
      @rhui_acs.save!
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:test_remote_name).returns('test-remote')
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

      @deb_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end

      @simplified_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end
      @simplified_acs.reload

      @rhui_acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
        ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      end
      @rhui_acs.reload
    end

    def test_yum_update
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      @yum_acs.update(base_url: 'https://yum.theforeman.org', subpaths: ['a_new_path/'])
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)

      pulp_acs = @yum_acs.backend_service(@primary).read
      pulp_remote = @yum_acs.backend_service(@primary).get_remote
      assert_equal @yum_acs.base_url, pulp_remote.url
      assert_equal @yum_acs.subpaths.sort, pulp_acs.paths.sort
    end

    def test_file_update
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      @file_acs.update(base_url: 'https://fixtures.pulpproject.org/', subpaths: ['file/', 'file-many/'])
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)

      pulp_acs = @file_acs.backend_service(@primary).read
      pulp_remote = @file_acs.backend_service(@primary).get_remote
      assert_equal @file_acs.base_url, pulp_remote.url
      assert_equal @file_acs.subpaths.collect { |s| s + '/PULP_MANIFEST' }.sort, pulp_acs.paths.sort
    end

    def test_deb_update
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@deb_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @deb_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      @deb_acs.update(base_url: 'https://fixtures.pulpproject.org/debian/', deb_releases: 'ragnarok ginnungagap')
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)

      pulp_remote = @deb_acs.backend_service(@primary).get_remote
      assert_equal @deb_acs.base_url, pulp_remote.url
      assert_equal 'ragnarok ginnungagap', pulp_remote.distributions
    end

    def test_file_update_no_subpaths
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      @file_acs.update(base_url: 'https://fixtures.pulpproject.org/file/')
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)

      pulp_acs = @file_acs.backend_service(@primary).read
      pulp_remote = @file_acs.backend_service(@primary).get_remote
      assert_equal @file_acs.base_url + '/PULP_MANIFEST', pulp_remote.url
      assert_equal [''], pulp_acs.paths
    end

    def test_http_proxy_url_update_file_acs
      proxy = FactoryBot.create(:http_proxy)
      proxy.update!(url: "https://test_url", username: "foo", password: "bar")

      @file_acs.update!(use_http_proxies: true)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      @file_acs.smart_proxy_alternate_content_sources.first.backend_service.smart_proxy.update!(http_proxy_id: proxy.id)
      remote_options = @file_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_equal remote_options[:proxy_url], proxy.url
      assert_equal remote_options[:proxy_username], proxy.username
      assert_equal remote_options[:proxy_password], proxy.password

      @file_acs.update(use_http_proxies: false)
      remote_options = @file_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_nil remote_options[:proxy_url]
      assert_nil remote_options[:proxy_username]
      assert_nil remote_options[:proxy_password]
    end

    def test_http_proxy_url_update_rhui_acs
      proxy = FactoryBot.create(:http_proxy)
      proxy.update!(url: "https://test_url", username: "foo", password: "bar")

      @rhui_acs.update!(use_http_proxies: true)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @rhui_acs.id, smart_proxy_id: @primary.id)
      @rhui_acs.smart_proxy_alternate_content_sources.first.backend_service.smart_proxy.update!(http_proxy_id: proxy.id)
      remote_options = @rhui_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_equal remote_options[:proxy_url], proxy.url
      assert_equal remote_options[:proxy_username], proxy.username
      assert_equal remote_options[:proxy_password], proxy.password

      @rhui_acs.update(use_http_proxies: false)
      remote_options = @rhui_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_nil remote_options[:proxy_url]
      assert_nil remote_options[:proxy_username]
      assert_nil remote_options[:proxy_password]
    end

    def test_http_proxy_url_update_simplified_acs
      proxy = FactoryBot.create(:http_proxy)
      proxy.update!(url: "https://test_url", username: "foo", password: "bar")

      # We stub this function so that simplified ACS remote options don't query candlepin
      ::Katello::Pulp3::Repository::Yum.any_instance.stubs(:remote_options).returns(
        {
          tls_validation: @rhui_acs.verify_ssl,
          name: "test_name",
          url: @rhui_acs.base_url,
          policy: 'on_demand',
          proxy_url: "https://bad_url",
          proxy_username: "bad_username",
          proxy_password: "bad_password",
          total_timeout: 42,
        }
      )

      @simplified_acs.update!(use_http_proxies: true)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @simplified_acs.id, smart_proxy_id: @primary.id, repository_id: @repository.id) # has repo
      @simplified_acs.smart_proxy_alternate_content_sources.first.backend_service.smart_proxy.update!(http_proxy_id: proxy.id)
      remote_options = @simplified_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_equal remote_options[:proxy_url], proxy.url
      assert_equal remote_options[:proxy_username], proxy.username
      assert_equal remote_options[:proxy_password], proxy.password

      @simplified_acs.update(use_http_proxies: false)
      remote_options = @simplified_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_nil remote_options[:proxy_url]
      assert_nil remote_options[:proxy_username]
      assert_nil remote_options[:proxy_password]
    end

    def test_http_proxy_url_update_deb_acs
      proxy = FactoryBot.create(:http_proxy)
      proxy.update!(url: "https://test_url", username: "foo", password: "bar")

      @deb_acs.update!(use_http_proxies: true)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @deb_acs.id, smart_proxy_id: @primary.id)
      @deb_acs.smart_proxy_alternate_content_sources.first.backend_service.smart_proxy.update!(http_proxy_id: proxy.id)

      remote_options = @deb_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_equal proxy.url, remote_options[:proxy_url]
      assert_equal proxy.username, remote_options[:proxy_username]
      assert_equal proxy.password, remote_options[:proxy_password]

      @deb_acs.update(use_http_proxies: false)
      remote_options = @deb_acs.smart_proxy_alternate_content_sources.first.backend_service.remote_options
      assert_nil remote_options[:proxy_url]
      assert_nil remote_options[:proxy_username]
      assert_nil remote_options[:proxy_password]
    end
  end
end
