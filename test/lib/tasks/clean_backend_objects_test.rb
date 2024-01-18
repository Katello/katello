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
    end

    def clear_hosts(except_id = -1)
      ::Katello::Host::ContentFacet.where("host_id != ?", except_id).destroy_all
      ::Katello::Host::SubscriptionFacet.where("host_id != ?", except_id).destroy_all
      ::Host.where("id != ?", except_id).destroy_all
    end

    def test_missing_nil_uuid
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      @host.subscription_facet.update!(:uuid => nil)
      mock_cp
      # this host will end up on the nil facets list and the no subscription
      # facet list. This is OK.
      Katello::RegistrationManager.expects(:unregister_host).with(@host, {}).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_managed_host
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      @host.update_column(:managed, true)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp

      Katello::RegistrationManager.expects(:unregister_host).with(@host, { :unregistering => true }).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_compute_resource_host
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      @host.update_column(:compute_resource_id, compute_resources(:mycompute).id)
      @host.subscription_facet.update!(:uuid => nil)
      mock_cp

      Katello::RegistrationManager.expects(:unregister_host).with(@host, { :unregistering => true }).once

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_cp_consumer_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp
      Katello::RegistrationManager.expects(:unregister_host).with(@host, {})

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_deletes_nothing_if_ids_present
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp([@host.subscription_facet.uuid])
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_no_commit_only_preview
      clear_hosts(@host.id)
      ENV['COMMIT'] = nil

      mock_cp
      Katello::RegistrationManager.expects(:unregister).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_no_commit
      clear_hosts
      ENV['COMMIT'] = nil
      mock_cp_uuid = 'cp-cool-id'
      mock_cp([mock_cp_uuid])

      Katello::Resources::Candlepin::Consumer.expects(:destroy).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_with_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp_uuid = 'cp-cool-id'

      mock_cp([mock_cp_uuid, @host.subscription_facet.uuid])

      Katello::Resources::Candlepin::Consumer.expects(:destroy).with(mock_cp_uuid)
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def mock_cp(value = [])
      Katello::Resources::Candlepin::Consumer.expects(:all_uuids).returns(value)
    end
  end
end
