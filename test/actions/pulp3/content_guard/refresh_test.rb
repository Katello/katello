require 'katello_test_helper'

module ::Actions::Pulp3::ContentGuard
  class ContentGuardRefreshTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    CERT_FIXTURE = "#{Katello::Engine.root}/test/fixtures/certs/content_guard.crt".freeze
    def setup
      @primary = SmartProxy.pulp_primary
      cert = File.read(CERT_FIXTURE)
      Cert::Certs.stubs(:candlepin_client_ca_cert).returns(cert)
    end

    def test_refresh_content_guard
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert_nil content_guard
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @primary)
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert content_guard
    end

    def test_single_content_guard
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 0
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @primary)
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 1
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @primary)
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 1
    end

    def test_for_creation
      name = 'test_for_creation'
      Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:default_name).returns(name)

      service = Katello::Pulp3::Api::ContentGuard.new(@primary)

      results = service.list(name: name).results
      results.each do |result|
        service.delete(result.pulp_href)
      end

      assert_equal 0, service.list(name: name).results.count

      task = ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @primary)

      assert :success, task.state
      assert_equal 1, ::Katello::Pulp3::ContentGuard.count
      assert_equal 1, service.list(name: name).results.count
    end
  end
end
