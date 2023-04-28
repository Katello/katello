namespace :katello do
  desc "Cleans backend objects (hosts) that are missing in one or more backend systems.  Run with COMMIT=true to commit changes."
  task :clean_backend_objects => ["environment", "check_ping"] do
    class BackendCleaner
      def initialize
        @candlepin_uuids = []
        @katello_candlepin_uuids = []
      end

      def populate!
        @candlepin_uuids = Katello::Resources::Candlepin::Consumer.all_uuids
        @katello_candlepin_uuids = Katello::Host::SubscriptionFacet.pluck(:uuid).compact
      end

      def hosts_with_no_subscriptions
        ::Host.where(:id => Katello::Host::SubscriptionFacet.where(:uuid => @katello_candlepin_uuids - @candlepin_uuids).select(:host_id))
      end

      def hosts_with_nil_facets
        nil_sub = Katello::Host::SubscriptionFacet.where(:uuid => nil).select(:host_id).to_sql
        ::Host.where(" id in (#{nil_sub})")
      end

      def cp_orphaned_host_uuids
        @candlepin_uuids - @katello_candlepin_uuids
      end
    end

    def cleanup_hosts(cleaner)
      cleaner.hosts_with_nil_facets.each do |host|
        print "Host #{host.id} #{host.name} is partially missing subscription information.  Un-registering\n"
        execute("Failed to delete host") { Katello::RegistrationManager.unregister_host(host, host_unregister_options(host)) }
      end

      cleaner.hosts_with_no_subscriptions.each do |host|
        print "Host #{host.id} #{host.name} #{host.subscription_facet.try(:uuid)} is partially missing subscription information.  Un-registering\n"
        execute("Failed to delete host") { Katello::RegistrationManager.unregister_host(host, host_unregister_options(host)) }
      end
    end

    def clean_backend_orphans(cleaner)
      cp_uuids = cleaner.cp_orphaned_host_uuids
      print "#{cp_uuids.count} orphaned consumer id(s) found in candlepin.\n"
      print "Candlepin orphaned consumers: #{cp_uuids}\n"
      cp_uuids.each do |consumer_id|
        execute("exception when destroying candlepin consumer #{consumer_id}") { Katello::Resources::Candlepin::Consumer.destroy(consumer_id) }
      end
    end

    def host_unregister_options(host)
      if host.managed? || host.compute_resource
        print "Leaving provisioning record for #{host.name} in place, it is either managed or assigned to a compute resource."
        {:unregistering => true}
      else
        {}
      end
    end

    def commit?
      ENV['COMMIT'] == 'true' || ENV['FOREMAN_UPGRADE'] == '1'
    end

    # rubocop:disable Lint/SuppressedException
    def execute(error_msg)
      if commit?
        yield
      end
    rescue RestClient::ResourceNotFound
    rescue => e
      print error_msg
      print e.inspect
    end

    unless commit?
      print "The following changes will not actually be performed.  Rerun with COMMIT=true to apply the changes\n"
    end

    SETTINGS[:katello][:candlepin][:bulk_load_size] = 125
    User.current = User.anonymous_admin
    cleaner = BackendCleaner.new
    cleaner.populate!

    cleanup_hosts(cleaner)
    clean_backend_orphans(cleaner)
  end
end
