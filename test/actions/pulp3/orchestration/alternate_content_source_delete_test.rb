require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceDeleteTest < ActiveSupport::TestCase
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

    def test_yum_delete
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @yum_acs, @primary)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, @yum_acs, @primary)
      assert_equal 0, @yum_acs.smart_proxy_alternate_content_sources.count
    end

    def test_file_delete
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, @file_acs, @primary)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, @file_acs, @primary)
      assert_equal 0, @file_acs.smart_proxy_alternate_content_sources.count
    end
  end
end
