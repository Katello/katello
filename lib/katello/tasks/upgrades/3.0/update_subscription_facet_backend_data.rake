namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :update_subscription_facet_backend_data => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Updating backend data for subscription facets")

        Katello::Host::SubscriptionFacet.find_each do |subscription_facet|
          begin
            candlepin_attrs = subscription_facet.candlepin_consumer.consumer_attributes
            subscription_facet.import_database_attributes(candlepin_attrs)

            subscription_facet.host = ::Host::Managed.find(subscription_facet.host_id)
            subscription_facet.save!

            Katello::Host::SubscriptionFacet.update_facts(subscription_facet.host, candlepin_attrs[:facts])
          rescue RestClient::Exception => exception
            Rails.logger.error exception
          end
        end

        #there may be some invalid hosts, if there are create a primary interface
        ::Host.includes(:interfaces).find_each do |host|
          if host.primary_interface.nil?
            host.interfaces.create!(:primary => true)
          end
        end
      end
    end
  end
end
