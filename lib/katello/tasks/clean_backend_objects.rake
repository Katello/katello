namespace :katello do
  desc "Cleans backend objects (hosts) that are missing in one or more backend systems.  Run with COMMIT=true to commit changes."
  task :clean_backend_objects => ["environment", "check_ping"] do
    class BackendCleaner
      def initialize
        @candlepin_uuids = []
        @pulp_uuids = []
        @katello_candlepin_uuids = []
        @katello_pulp_uuids = []
      end

      def populate!
        @candlepin_uuids = Katello::Resources::Candlepin::Consumer.all_uuids
        @katello_candlepin_uuids = Katello::Host::SubscriptionFacet.pluck(:uuid).compact

        @pulp_uuids = ::Katello.pulp_server.extensions.consumer.retrieve_all.map { |consumer| consumer['id'] }
        @katello_pulp_uuids = Katello::Host::ContentFacet.pluck(:uuid).compact
      end

      def hosts_with_no_subscriptions
        ::Host.where(:id => Katello::Host::SubscriptionFacet.where(:uuid => @katello_candlepin_uuids - @candlepin_uuids).select(:host_id))
      end

      def hosts_with_no_content
        ::Host.where(:id => Katello::Host::ContentFacet.where(:uuid => @katello_pulp_uuids - @pulp_uuids).select(:host_id))
      end

      def hosts_with_nil_facets
        nil_sub = Katello::Host::SubscriptionFacet.where(:uuid => nil).select(:host_id).to_sql
        ::Host.where(" id in (#{nil_sub})")
      end

      def cp_orphaned_host_uuids
        @candlepin_uuids - @katello_candlepin_uuids
      end

      def pulp_orphaned_host_uuids
        @pulp_uuids - @katello_pulp_uuids
      end
    end

    def cleanup_hosts(cleaner)
      cleaner.hosts_with_nil_facets.each do |host|
        print "Host #{host.id} #{host.name} is partially missing subscription information.  Un-registering\n"
        execute("Failed to delete host") { Katello::RegistrationManager.unregister_host(host) }
      end

      cleaner.hosts_with_no_subscriptions.each do |host|
        print "Host #{host.id} #{host.name} #{host.subscription_facet.try(:uuid)} is partially missing subscription information.  Un-registering\n"
        execute("Failed to delete host") { Katello::RegistrationManager.unregister_host(host) }
      end

      cleaner.hosts_with_no_content.each do |host|
        print "Host #{host.id} #{host.name} #{host.content_facet.try(:uuid)} is partially missing content information.  Un-registering\n"
        execute("Failed to delete host") { Katello::RegistrationManager.unregister_host(host) }
      end
    end

    def clean_backend_orphans(cleaner)
      cp_uuids = cleaner.cp_orphaned_host_uuids
      print "#{cp_uuids.count} orphaned consumer id(s) found in candlepin.\n"
      cp_uuids.each do |consumer_id|
        execute("exception when destroying candlepin consumer #{consumer_id}") { Katello::Resources::Candlepin::Consumer.destroy(consumer_id) }
      end

      pulp_uuids = cleaner.pulp_orphaned_host_uuids
      print "#{pulp_uuids.count} orphaned consumer id(s) found in pulp.\n"
      pulp_uuids.each do |consumer_id|
        execute("exception when destroying pulp consumer #{consumer_id}") { Katello.pulp_server.extensions.consumer.delete(consumer_id) }
      end
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

    unless ENV['COMMIT'] == 'true'
      print "The following changes will not actually be performed.  Rerun with COMMIT=true to apply the changes\n"
    end

    SETTINGS[:katello][:candlepin][:bulk_load_size] = 15_000
    User.current = User.anonymous_admin
    cleaner = BackendCleaner.new
    cleaner.populate!

    cleanup_hosts(cleaner)
    clean_backend_orphans(cleaner)
  end
end
