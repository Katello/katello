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
                         "versions" => {"platform_version" => "2.9.1",
                          },
                        }
    end

    def test_ping_with_errors
      exception = assert_raises(StandardError) do
        Katello::Ping.ping!
      end

      assert_match(/The following services/, exception.message)
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

    def test_candlepin_ping_ok
      Katello::Resources::Candlepin::CandlepinPing.expects(:ping).returns(mode: 'NORMAL')

      response = Katello::Ping.ping_candlepin_with_auth({})

      assert_equal 'ok', response[:status]
    end

    def test_candlepin_ping_suspend_fail
      Katello::Resources::Candlepin::CandlepinPing.expects(:ping).returns(mode: 'SUSPEND')

      assert_equal({status: 'FAIL', message: 'Candlepin is not running properly'}, Katello::Ping.ping_candlepin_with_auth({}))
    end

    def test_candlepin_ping_fail
      Katello::Resources::Candlepin::CandlepinPing.expects(:ping).raises(StandardError.new('yikes'))

      assert_equal({status: 'FAIL', message: 'yikes'}, Katello::Ping.ping_candlepin_with_auth({}))
    end

    def test_candlepin_unauth_ping_ok
      Katello::Ping.expects(:backend_status).returns(mode: 'NORMAL')

      response = Katello::Ping.ping_candlepin_without_auth({})

      assert_equal 'ok', response[:status]
    end

    def test_candlepin_unauth_ping_fail
      Katello::Ping.expects(:backend_status).raises(StandardError.new('yikes'))

      assert_equal({status: 'FAIL', message: 'yikes'}, Katello::Ping.ping_candlepin_without_auth({}))
    end

    def test_candlepin_unauth_ping_suspend_fail
      Katello::Ping.expects(:backend_status).returns(mode: 'SUSPEND')

      assert_equal({status: 'FAIL', message: 'Candlepin is not running properly'}, Katello::Ping.ping_candlepin_without_auth({}))
    end

    def test_ping_candlepin_events
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:candlepin_events)
        .returns(processed_count: 0, failed_count: 0, running: true)

      result = Katello::Ping.ping_candlepin_events({})

      assert_equal 'ok', result[:status]
      assert_equal '0 Processed, 0 Failed', result[:message]
    end

    def test_ping_candlepin_events_starting
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:candlepin_events)
        .returns(running: 'starting')

      result = Katello::Ping.ping_candlepin_events({})

      assert_equal 'ok', result[:status]
      assert_equal '0 Processed, 0 Failed', result[:message]
    end

    def test_ping_candlepin_not_running
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:candlepin_events)
        .returns(processed_count: 10, failed_count: 5, running: false)

      result = Katello::Ping.ping_candlepin_events({})

      assert_equal 'FAIL', result[:status]
      assert_equal 'Not running', result[:message]
    end

    def test_ping_katello_events
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:katello_events)
        .returns(processed_count: 0, failed_count: 0, running: true)

      result = Katello::Ping.ping_katello_events({})

      assert_equal 'ok', result[:status]
      assert_equal '0 Processed, 0 Failed', result[:message]
    end

    def test_ping_katello_events_starting
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:katello_events)
        .returns(running: 'starting')

      result = Katello::Ping.ping_katello_events({})

      assert_equal 'ok', result[:status]
      assert_equal '0 Processed, 0 Failed', result[:message]
    end

    def test_ping_katello_events_not_running
      Katello::EventDaemon::Runner
        .expects(:service_status).with(:katello_events)
        .returns(processed_count: 10, failed_count: 5, queue_depth: 1001)

      result = Katello::Ping.ping_katello_events({})

      assert_equal 'FAIL', result[:status]
      assert_equal 'Not running', result[:message]
    end
  end

  class PingTestPulp3 < ActiveSupport::TestCase
    def run_exception_test(json, message)
      Katello::Ping.expects(:backend_status).returns(json)
      exception = assert_raises Exception do
        Katello::Ping.pulp3_without_auth(@url)
      end
      assert_match message, exception.message
    end

    def setup
      @ok_pulp_status = {"versions" =>
                        [{"component" => "pulpcore", "version" => "3.0.0rc2"},
                         {"component" => "pulpcore-plugin", "version" => "0.1.0rc2"},
                         {"component" => "pulp_file", "version" => "0.0.1b11"}],
                         "online_workers" =>
                         [{"_href" => "/pulp/api/v3/workers/34f275cd-3df6-4a75-89a3-a00398e667f5/",
                           "pulp_created" => "2019-06-12T02:23:03.609253Z",
                           "name" => "resource-manager@zeta.partello.example.com",
                           "last_heartbeat" => "2019-06-13T18:59:39.653124Z",
                           "online" => true,
                           "missing" => false},
                          {"_href" => "/pulp/api/v3/workers/a158c692-6b2e-4b91-939b-f0b1878d90e3/",
                           "pulp_created" => "2019-06-12T02:22:56.379511Z",
                           "name" => "reserved-resource-worker-1@zeta.partello.example.com",
                           "last_heartbeat" => "2019-06-13T18:59:40.006524Z",
                           "online" => true,
                           "missing" => false}
                         ],
                         "online_content_apps" =>
                         [{"last_heartbeat": "2021-10-20T13:32:36.817752Z",
                           "name": "3835@katello.example.com"}
                         ],
                         "missing_workers" => [],
                         "database_connection" => {"connected" => true},
                         "redis_connection" => {"connected" => true}}

      @url = "http://pulp3/api"
    end

    def test_failure_on_empty_json
      run_exception_test({}, /Pulp does not appear to be running/)
    end

    def test_failure_on_bad_db
      run_exception_test({"database_connection" => {"connected" => false}},
                           /Pulp database connection issue/)
    end

    def test_failure_on_bad_redis
      run_exception_test({ "database_connection" => {"connected" => true},
                           "redis_connection" => {"connected" => false}},
                           /Pulp redis connection issue/)
    end

    def test_failure_on_all_workers
      run_exception_test({ "database_connection" => {"connected" => true},
                           "redis_connection" => {"connected" => true},
                          }, /No pulpcore workers are running at/)
    end

    def test_failure_on_all_workers_empty
      run_exception_test({ "database_connection" => {"connected" => true},
                           "redis_connection" => {"connected" => true},
                           "online_workers" => [],
                          }, /No pulpcore workers are running at/)
    end

    def test_failure_on_no_reserved_resource_worker
      run_exception_test({ "database_connection" => {"connected" => true},
                           "redis_connection" => {"connected" => true},
                           "online_workers" => [],
                          }, /No pulpcore workers are running at/)
    end

    def test_failure_on_content_apps_empty
      json = { "database_connection" => {"connected" => true},
               "redis_connection" => {"connected" => true},
               "online_workers" => @ok_pulp_status['online_workers'],
               "online_content_apps" => [],
      }
      message = /No pulpcore content apps are running at/

      Katello::Ping.expects(:backend_status).returns(json)
      exception = assert_raises Exception do
        Katello::Ping.pulp3_content_without_auth(@url)
      end
      assert_match message, exception.message
    end

    def test_all_workers_present_ok_status
      Katello::Ping.expects(:backend_status).returns(@ok_pulp_status)
      assert_equal @ok_pulp_status, Katello::Ping.pulp3_without_auth(@url)
    end
  end
end
