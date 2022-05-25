require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @yum_acs.save!
      @file_acs.save!
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:test_remote_name).returns('test-remote')
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

    def test_yum_update
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @yum_acs, @primary)
      @yum_acs.update(base_url: 'https://yum.theforeman.org', subpaths: ['a_new_path/'])
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, @yum_acs, @primary)

      pulp_acs = @yum_acs.backend_service(@primary).read
      pulp_remote = @yum_acs.backend_service(@primary).get_remote
      assert_equal @yum_acs.base_url, pulp_remote.url
      assert_equal @yum_acs.subpaths.sort, pulp_acs.paths.sort
    end

    def test_file_update
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @file_acs, @primary)
      @file_acs.update(base_url: 'https://fixtures.pulpproject.org/', subpaths: ['file/', 'file-many/'])
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, @file_acs, @primary)

      pulp_acs = @file_acs.backend_service(@primary).read
      pulp_remote = @file_acs.backend_service(@primary).get_remote
      assert_equal @file_acs.base_url, pulp_remote.url
      assert_equal @file_acs.subpaths.collect { |s| s + '/PULP_MANIFEST' }.sort, pulp_acs.paths.sort
    end

    def test_file_update_no_subpaths
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @file_acs, @primary)
      @file_acs.update(base_url: 'https://fixtures.pulpproject.org/file/')
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Update, @file_acs, @primary)

      pulp_acs = @file_acs.backend_service(@primary).read
      pulp_remote = @file_acs.backend_service(@primary).get_remote
      assert_equal @file_acs.base_url + '/PULP_MANIFEST', pulp_remote.url
      assert_equal [''], pulp_acs.paths
    end
  end
end
