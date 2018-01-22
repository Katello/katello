namespace :katello do
  namespace :upgrades do
    namespace '3.6' do
      desc "Import product content from Candlepin to improve API performance and enhance searching"
      task :import_backend_consumer_attributes => %w(environment check_ping) do
        def log_message(org, count, total)
          if count % 25 == 1 || count == total
            puts "Importing consumer: #{org.name}: #{count}/#{total}"
          end
        end

        User.current = User.anonymous_admin
        Organization.all.each do |org|
          consumers = ::Katello::Resources::Candlepin::Consumer.get(:owner => org.label,
                                                                     :include_only => %w(uuid installedProducts.productId
                                                                                         installedProducts.productName installedProducts.version
                                                                                         installedProducts.arch))
          consumer_count = 1
          consumers.each do |consumer|
            log_message(org, consumer_count, consumers.count)
            facet = Katello::Host::SubscriptionFacet.find_by(:uuid => consumer['uuid'])
            if facet
              facet.update_installed_products(consumer['installedProducts'])
              facet.update_compliance_reasons(Katello::Resources::Candlepin::Consumer.compliance(facet.uuid)['reasons'])
            end
            consumer_count += 1
          end
        end
      end
    end
  end
end
