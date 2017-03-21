namespace :katello do
  desc "Cleans backend objects (hosts) that are missing in one or more backend systems.  Run with COMMIT=true to commit changes."
  task :clean_backend_objects => ["environment", "check_ping"] do
    def cleanup_hosts
      Host.includes(:content_facet, :subscription_facet).find_each do |host|
        if test_candlepin(host) || test_pulp(host)
          print "Host #{host.id} #{host.name} #{host.subscription_facet.try(:uuid)} is partially missing.  Un-registering\n"
          execute("Failed to delete host") { ForemanTasks.sync_task(::Actions::Katello::Host::Unregister, host) }
        end
      end
    end

    def test_pulp(host)
      if host.content_facet.try(:uuid)
        test_method { Katello.pulp_server.extensions.consumer.retrieve(host.content_facet.uuid) }
      else
        false
      end
    end

    def test_candlepin(host)
      if host.subscription_facet && host.subscription_facet.uuid
        test_method { ::Katello::Resources::Candlepin::Consumer.get(host.subscription_facet.uuid) }
      elsif host.subscription_facet
        true
      else
        false
      end
    end

    def test_method
      yield
      false
    rescue RestClient::ResourceNotFound
      true
    rescue RestClient::Gone
      true
    rescue RestClient::Conflict
      true
    end

    # rubocop:disable HandleExceptions
    def execute(error_msg)
      if ENV['COMMIT'] == 'true'
        yield
      end
    rescue RestClient::ResourceNotFound
    rescue => e
      print error_msg
      print e.inspect
    end

    def clean_backend_orphans
      consumer_ids = Katello::Candlepin::Consumer.orphaned_consumer_ids
      print "#{consumer_ids.count} orphaned consumer id(s) found.\n"
      consumer_ids.each do |consumer_id|
        execute("exception when destroying candlepin consumer #{consumer_id}") { Katello::Resources::Candlepin::Consumer.destroy(consumer_id) }
        execute("exception when destroying pulp consumer #{consumer_id}") { Katello.pulp_server.extensions.consumer.delete(consumer_id) }
      end
    end

    unless ENV['COMMIT'] == 'true'
      print "The following changes will not actually be performed.  Rerun with COMMIT=true to apply the changes\n"
    end

    User.current = User.anonymous_admin
    cleanup_hosts
    clean_backend_orphans
  end
end
