require 'katello_test_helper'
require 'rest-client'

module Katello
  class PingTest < ActiveSupport::TestCase
    def setup
      @ok_pulp_status = {"known_workers" =>
                          [
                            {"_ns" => "workers", "last_heartbeat" => "2016-09-13T20:07:54Z", "_id" => "scheduler@chicken.example.com"},
                            {"_ns" => "workers", "last_heartbeat" => "2016-09-13T20:08:21Z", "_id" => "resource_manager@chicken.example.com"},
                            {"_ns" => "workers", "last_heartbeat" => "2016-09-13T20:08:20Z", "_id" => "reserved_resource_worker-1@chicken.example.com"},
                            {"_ns" => "workers", "last_heartbeat" => "2016-09-13T20:08:20Z", "_id" => "reserved_resource_worker-0@chicken.example.com"}
                          ],
                         "messaging_connection" => {"connected" => true},
                         "database_connection" => {"connected" => true},
                         "api_version" => "2",
                         "versions" => {"platform_version" => "2.9.1"
                          }
                        }
    end

    def test_all_workers_present_ok_status
      assert Katello::Ping.all_pulp_workers_present?(@ok_pulp_status)
    end

    def test_all_workers_present_no_scheduler
      no_scheduler_status = @ok_pulp_status
      no_scheduler_status["known_workers"].delete_if { |x| x["_id"] == "scheduler@chicken.example.com" }
      refute Katello::Ping.all_pulp_workers_present?(no_scheduler_status)
    end

    def test_all_workers_present_no_resource_manager
      no_resource_manager_status = @ok_pulp_status
      no_resource_manager_status["known_workers"].delete_if { |x| x["_id"] == "resource_manager@chicken.example.com" }
      refute Katello::Ping.all_pulp_workers_present?(no_resource_manager_status)
    end

    def test_all_workers_present_no_reserved_resource_worker
      no_reserved_resource_worker_status = @ok_pulp_status
      no_reserved_resource_worker_status["known_workers"].delete_if { |x| x["_id"] =~ /reserved_resource_worker-./ }
      refute Katello::Ping.all_pulp_workers_present?(no_reserved_resource_worker_status)
    end
  end
end
