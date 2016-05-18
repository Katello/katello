namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :update_subscription_facet_backend_data => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Updating backend data for subscription facets")

        Katello::Host::SubscriptionFacet.find_each do |subscription_facet|
          begin
            subscription_facet.update_from_consumer_attributes(subscription_facet.candlepin_consumer.consumer_attributes)
          rescue RestClient::Exception => exception
            Rails.logger.error exception
          end
          subscription_facet.host = ::Host::Managed.find(subscription_facet.host_id)
          subscription_facet.save!
        end
      end
    end
  end
end
