namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :update_subscription_facet_backend_data => ["environment"] do
        def error(message)
          @errors << message
          @errors << "\n"
        end

        def report_errors
          if @errors.any?
            filename = "subscription_facet_upgrade-#{Time.now.to_i}.log"
            path = "/var/log/foreman/#{filename}"
            path = "/tmp/#{filename}" unless File.writable?(path)

            file = File.open(path, 'w')
            @errors.each { |error| file.write(error) }
            file.close
            $stderr.print "***********************************\n"
            $stderr.print "*************WARNING***************\n"
            $stderr.print "Errors detected during upgrade step.\n"
            $stderr.print "Details saved to: #{file.path}\n"
            $stderr.print "This step can be rerun with:\n"
            $stderr.print "  foreman-rake katello:upgrades:3.0:update_subscription_facet_backend_data\n"
            $stderr.print "You are likely encountering a bug.\n"
            $stderr.print "***********************************\n"
          end
        end

        @errors ||= []
        User.current = User.anonymous_api_admin
        puts _("Updating backend data for subscription facets")

        #there may be some invalid hosts, if there are create a primary interface
        ::Host.includes(:interfaces).find_each do |host|
          if host.primary_interface.nil?
            host.interfaces.create!(:primary => true)
          end
        end

        Katello::Host::SubscriptionFacet.find_each do |subscription_facet|
          begin
            candlepin_attrs = subscription_facet.candlepin_consumer.consumer_attributes
            subscription_facet.import_database_attributes(candlepin_attrs)
            subscription_facet.host = ::Host::Managed.find(subscription_facet.host_id)
            subscription_facet.save!

            host = subscription_facet.host
            host.name = ::Katello::Host::SubscriptionFacet.sanitize_name(host.name)
            host.save! if host.name_changed?

            Katello::Host::SubscriptionFacet.update_facts(subscription_facet.host, candlepin_attrs[:facts])
          rescue StandardError => exception
            error("Error: #{subscription_facet.host.name} - #{subscription_facet.host.id}")
            error(candlepin_attrs)
            error(exception.message)
            error(exception.backtrace.join("\n"))
            error("\n")
          end
        end
        report_errors
      end
    end
  end
end
