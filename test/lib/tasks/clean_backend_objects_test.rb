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

      @host.subscription_facet.update_attributes!(:uuid => nil)
      mock_cp
      mock_pulp
      # this host will end up on the nil facets list and the no subscription
      # facet list. This is OK.
      Katello::RegistrationManager.expects(:unregister_host).with(@host).twice

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_cp_consumer_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp
      mock_pulp([{"id" => @host.content_facet.uuid}])
      Katello::RegistrationManager.expects(:unregister_host).with(@host)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_pulp_consumer_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp([@host.subscription_facet.uuid])
      mock_pulp
      Katello::RegistrationManager.expects(:unregister_host).with(@host)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_deletes_nothing_if_ids_present
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp([@host.subscription_facet.uuid])
      mock_pulp([{"id" => @host.content_facet.uuid}])
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_no_commit_only_preview
      clear_hosts(@host.id)
      ENV['COMMIT'] = nil

      mock_cp
      mock_pulp([{"id" => @host.content_facet.uuid}])
      Katello::RegistrationManager.expects(:unregister).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_no_commit
      clear_hosts
      ENV['COMMIT'] = nil
      mock_cp_uuid = 'cp-cool-id'
      mock_pulp_uuid = 'pulp-cool-id'
      mock_cp([mock_cp_uuid])
      mock_pulp([{"id" => mock_pulp_uuid}])

      Katello::Resources::Candlepin::Consumer.expects(:destroy).never
      Katello.pulp_server.extensions.consumer.expects(:delete).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_with_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      mock_cp_uuid = 'cp-cool-id'
      mock_pulp_uuid = 'pulp-cool-id'

      mock_cp([mock_cp_uuid, @host.subscription_facet.uuid])
      mock_pulp([{"id" => mock_pulp_uuid}, {"id" => @host.content_facet.uuid}])

      Katello::Resources::Candlepin::Consumer.expects(:destroy).with(mock_cp_uuid)
      Katello.pulp_server.extensions.consumer.expects(:delete).with(mock_pulp_uuid)
      Katello::RegistrationManager.expects(:unregister).never
      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def mock_cp(value = [])
      Katello::Resources::Candlepin::Consumer.expects(:all_uuids).returns(value)
    end

    def mock_pulp(value = [])
      content = mock(:retrieve_all => value)
      extensions = stub(:consumer => content)
      pulp_server = stub(:extensions => extensions)
      Katello.stubs(:pulp_server).returns(pulp_server)
    end
  end
end
