require 'katello_test_helper'

module Katello
  class TraceStatusTest < ActiveSupport::TestCase
    let(:host) do
      FactoryGirl.create(:host, :with_content, :content_view => katello_content_views(:library_dev_view),
                         :lifecycle_environment => katello_environments(:library))
    end

    let(:status) { host.get_status(Katello::TraceStatus) }

    def test_get_status
      assert host.get_status(Katello::TraceStatus)
    end

    def test_to_status_static
      host.host_traces.create!(:application => "dbus-daemon", :helper => "You will have to reboot your computer", :app_type => "static")
      assert_equal Katello::TraceStatus::REQUIRE_REBOOT, status.to_status
    end

    def test_to_status_daemon
      host.host_traces.create!(:application => "goferd", :helper => "sudo systemctl restart goferd", :app_type => "daemon")
      assert_equal Katello::TraceStatus::REQUIRE_PROCESS_RESTART, status.to_status
    end

    def test_to_status_session
      host.host_traces.create!(:application => "bash", :helper => "You will have to log out & log in again", :app_type => "session")
      assert_equal Katello::TraceStatus::UP_TO_DATE, status.to_status
    end

    def test_to_status_no_traces
      assert_equal Katello::TraceStatus::UP_TO_DATE, status.to_status
    end

    def test_no_content_facet
      assert_equal Katello::TraceStatus::UP_TO_DATE, FactoryGirl.build(:host).get_status(Katello::TraceStatus).to_status
    end

    def test_to_global
      status.status = Katello::TraceStatus::UP_TO_DATE
      assert_equal HostStatus::Global::OK, status.to_global
    end
  end
end
