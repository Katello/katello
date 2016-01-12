module Katello
  module Concerns
    module SmartProxiesControllerExtensions
      extend ActiveSupport::Concern

      def pulp_status
        find_resource
        find_status
        requested_data(@proxy_status[:pulp], :pulp_status)
      end

      def action_permission
        case params[:action]
          when 'pulp_status'
            :view
          else
            super
        end
      end
    end
  end
end
