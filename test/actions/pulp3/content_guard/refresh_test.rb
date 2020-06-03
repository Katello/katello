require 'katello_test_helper'

module ::Actions::Pulp3::ContentGuard
  class ContentGuardRefreshTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    CERT_FIXTURE = "#{Katello::Engine.root}/test/fixtures/certs/content_guard.crt".freeze
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      cert = File.read(CERT_FIXTURE)
      Cert::Certs.stubs(:ca_cert).returns(cert)
    end

    def test_refresh_content_guard
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert_nil content_guard
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @master)
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert content_guard
    end

    def test_single_content_guard
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 0
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @master)
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 1
      ForemanTasks.sync_task(::Actions::Pulp3::ContentGuard::Refresh, @master)
      content_guard_count = ::Katello::Pulp3::ContentGuard.count
      assert_equal content_guard_count, 1
    end
  end
end
