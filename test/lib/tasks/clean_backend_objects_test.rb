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

      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns([])

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Host::Unregister, @host)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_cp_consumer_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      ::Katello::Resources::Candlepin::Consumer.expects(:get).with(@host.subscription_facet.uuid).raises(RestClient::Gone)
      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns([])

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Host::Unregister, @host)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_pulp_consumer_commit
      clear_hosts(@host.id)
      ENV['COMMIT'] = 'true'

      ::Katello::Resources::Candlepin::Consumer.expects(:get).with(@host.subscription_facet.uuid).returns({})
      Runcible::Extensions::Consumer.any_instance.expects(:retrieve).with(@host.content_facet.uuid).raises(RestClient::ResourceNotFound)

      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns([])
      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Host::Unregister, @host)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_missing_cp_consumer
      clear_hosts(@host.id)
      ENV['COMMIT'] = nil

      ::Katello::Resources::Candlepin::Consumer.expects(:get).with(@host.subscription_facet.uuid).raises(RestClient::Gone)
      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns([])

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Host::Unregister, @host).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned
      clear_hosts
      ENV['COMMIT'] = nil
      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns(['orphaned'])
      Katello::Resources::Candlepin::Consumer.expects(:destroy).never
      Katello.pulp_server.extensions.consumer.expects(:delete).never

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_commit
      ENV['COMMIT'] = 'true'
      clear_hosts
      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns(['orphaned'])
      Katello::Resources::Candlepin::Consumer.expects(:destroy).with('orphaned')
      Runcible::Extensions::Consumer.any_instance.expects(:delete).with('orphaned')

      Rake.application.invoke_task('katello:clean_backend_objects')
    end

    def test_orphaned_404_pulp_commit
      ENV['COMMIT'] = 'true'
      clear_hosts
      Katello::Candlepin::Consumer.expects(:orphaned_consumer_ids).returns(['orphaned'])
      Katello::Resources::Candlepin::Consumer.expects(:destroy).with('orphaned')
      Runcible::Extensions::Consumer.any_instance.expects(:delete).with('orphaned').raises(RestClient::ResourceNotFound)

      Rake.application.invoke_task('katello:clean_backend_objects')
    end
  end
end
