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
  end
end
