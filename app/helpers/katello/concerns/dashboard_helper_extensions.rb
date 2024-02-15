module Katello
  module Concerns
    module DashboardHelperExtensions
      def host_query
        ::Host::Managed.authorized('view_hosts', ::Host::Managed).where(:organization => Organization.current)
      end

      def total_host_count
        host_query.size
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
