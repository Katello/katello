require 'katello_test_helper'

module ::Actions::Pulp3
  class AlternateContentSourceDeleteTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @deb_acs = katello_alternate_content_sources(:deb_alternate_content_source)
      @yum_acs.save!
      @file_acs.save!
      @deb_acs.save!
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
      @deb_acs.reload
    end

    def test_yum_delete
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@yum_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      assert_equal 0, @yum_acs.smart_proxy_alternate_content_sources.count
    end

    def test_file_delete
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@file_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      assert_equal 0, @file_acs.smart_proxy_alternate_content_sources.count
    end

    def test_deb_delete
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@deb_acs.name)
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @deb_acs.id, smart_proxy_id: @primary.id)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
      assert_equal 0, @deb_acs.smart_proxy_alternate_content_sources.count
    end
  end
end
