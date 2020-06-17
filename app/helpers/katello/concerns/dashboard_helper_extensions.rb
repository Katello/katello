module Katello
  module Concerns
    module DashboardHelperExtensions
      def host_query
        ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current)
      end

      def total_host_count
        host_query.size
      end

      def partial_consumer_count
        host_query.search_for("subscription_status = partial").size
      end

      def valid_consumer_count
        host_query.search_for("subscription_status = valid").size
      end

      def invalid_consumer_count
        host_query.search_for("subscription_status = invalid").size
      end

      def unknown_consumer_count
        host_query.search_for("subscription_status = unknown or (null? subscription_uuid)").size
      end

      def unsubscribed_hypervisor_count
        host_query.search_for("subscription_status = unsubscribed_hypervisor").size
      end

      def removed_widgets
        widgets = super

        if Organization.current&.simple_content_access?
          widgets.reject! { |widget| ::Widget.singleton_class::SUBSCRIPTION_TEMPLATES.include? widget[:template] }
        end

        widgets
      end
    end
  end
end
