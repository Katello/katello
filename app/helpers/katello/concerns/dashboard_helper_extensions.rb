module Katello
  module Concerns
    module DashboardHelperExtensions
      def host_query
        ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current)
      end

      def total_host_count
        host_query.size
      end
    end
  end
end
