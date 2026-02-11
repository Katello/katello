require 'katello_test_helper'
require 'rake'

module Katello
  class CleanBackendObjectsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/clean_backend_objects'
      Rake.application.rake_require 'katello/tasks/reimport'

      Rake::Task['katello:clean_backend_objects'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')
      Katello::Ping.expects(:ping).returns(:status => 'ok')
      @host = hosts(:one)
      @original_stdout = $stdout
      $stdout = StringIO.new
    end

    def teardown
      $stdout = @original_stdout
    end

    def clear_hosts(except_id = -1)
      ::Katello::Host::ContentFacet.where("host_id != ?", except_id).destroy_all
      ::Katello::Host::SubscriptionFacet.where("host_id != ?", except_id).destroy_all
      ::Host.where("id != ?", except_id).destroy_all
    end

    def test_missing_nil_uuid
      clear_hosts(@host.id)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp
      # this host will end up on the nil facets list and the no subscription
      # facet list. This is OK.
      Katello::RegistrationManager.expects(:unregister_host).with(@host, {}).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_managed_host
      clear_hosts(@host.id)
      @host.update_column(:managed, true)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp

      Katello::RegistrationManager.expects(:unregister_host).with(@host, { :unregistering => true }).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_non_managed_host_deletion
      clear_hosts(@host.id)
      @host.update_column(:managed, false)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp

      Katello::Resources::Candlepin::Consumer.stubs(:destroy)

      Rake.application.invoke_task('katello:clean_backend_objects')

      assert_nil ::Host::Managed.find_by(id: @host.id), "Host was not deleted"
    end

    def test_compute_resource_host
      clear_hosts(@host.id)
      @host.update_column(:compute_resource_id, compute_resources(:mycompute).id)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp

      Katello::RegistrationManager.expects(:unregister_host).with(@host, { :unregistering => true }).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_cp_consumer
      clear_hosts(@host.id)
      mock_cp
      Katello::RegistrationManager.expects(:unregister_host).with(@host, {})

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_deletes_nothing_if_ids_present
      clear_hosts(@host.id)
      mock_cp([@host.subscription_facet.uuid])
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned
      clear_hosts(@host.id)
      mock_cp_uuid = 'cp-cool-id'
      mock_cp([mock_cp_uuid, @host.subscription_facet.uuid])

      Katello::Resources::Candlepin::Consumer.expects(:destroy).with(mock_cp_uuid)
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def mock_cp(value = [])
      Katello::Resources::Candlepin::Consumer.expects(:all_uuids).returns(value)
    end

    def test_logger_errors
      clear_hosts(@host.id)
      error = { type: "MockError", message: "something went wrong" }
      task_output = {
        results: {
          hosts_with_nil_facets: [],
          hosts_with_no_subscriptions: [],
          orphaned_consumers: [],
          errors: [error],
        },
      }
      mock_task = mock('task', output: task_output)
      ForemanTasks.expects(:sync_task).returns(mock_task)

      Rails.logger.expects(:error).with("MockError: something went wrong")

      Rake.application.invoke_task('katello:clean_backend_objects')
    end
  end
end
