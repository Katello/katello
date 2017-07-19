module Katello
  module Concerns
    module DashboardHelperExtensions
      def total_host_count
        total_host_count = ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current).size
        return total_host_count || 0
      end

      def partial_consumer_count
        partial_consumer_count = ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current).search_for("subscription_status = partial").size
        return partial_consumer_count || 0
      end

      def valid_consumer_count
        valid_consumer_count = ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current).search_for("subscription_status = valid").size
        return valid_consumer_count || 0
      end

      def invalid_consumer_count
        invalid_consumer_count = ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current).search_for("subscription_status = invalid").size
        return invalid_consumer_count || 0
      end

      def unknown_consumer_count
        unknown_consumer_count = ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current).search_for("subscription_status = unknown").size
        return unknown_consumer_count || 0
      end
    end
  end
end
